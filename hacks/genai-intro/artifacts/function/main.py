import base64
import json
import os

from itertools import islice
from typing import Sequence

import vertexai

from google.cloud import bigquery
from google.cloud import storage
from google.cloud import vision

from vertexai.language_models import TextGenerationModel


PROJECT_ID=os.getenv("GCP_PROJECT_ID")
STAGING_BUCKET=f"{PROJECT_ID}-staging"

BQ_DATASET="articles"
BQ_TABLE="summaries"


def extract_text_from_document(src_bucket: str, file_name: str, dst_bucket: str) -> str:
    src_uri = f"gs://{src_bucket}/{file_name}"
    dst_uri = f"gs://{dst_bucket}/{file_name}/"
    mime_type = "application/pdf"
    batch_size = 2

    # Perform Vision OCR
    client = vision.ImageAnnotatorClient()
    feature = vision.Feature(type_=vision.Feature.Type.DOCUMENT_TEXT_DETECTION)

    gcs_source = vision.GcsSource(uri=src_uri)
    input_config = vision.InputConfig(gcs_source=gcs_source, mime_type=mime_type)

    gcs_destination = vision.GcsDestination(uri=dst_uri)
    output_config = vision.OutputConfig(
        gcs_destination=gcs_destination, batch_size=batch_size
    )

    async_request = vision.AsyncAnnotateFileRequest(
        features=[feature], input_config=input_config, output_config=output_config
    )

    operation = client.async_batch_annotate_files(requests=[async_request])

    operation.result(timeout=420)

    return f"{file_name}/"


def collate_pages(bucket: str, folder: str) -> str:
    storage_client = storage.Client(project=PROJECT_ID)
    bucket = storage_client.get_bucket(bucket)
    blob_list = [blob for blob in list(bucket.list_blobs(prefix=folder))]

    complete_text = ""
    for output in blob_list:
        json_string = output.download_as_bytes().decode("utf-8")
        response = json.loads(json_string)
        for page in response["responses"]:
            complete_text += page["fullTextAnnotation"]["text"]

    return complete_text


def get_prompt_for_title_extraction() -> str:
    # TODO provide the prompt, you can use $ references for substitution
    # See https://docs.python.org/3/library/string.html#template-strings
    return ""  


def extract_title_from_text(text: str) -> str:
    vertexai.init(project=PROJECT_ID, location="us-central1")  # PaLM only available in us for now
    model = TextGenerationModel.from_pretrained("text-bison@latest")
    # Give away the full code, externalize prompt, and let people edit the prompt file and enter the mapping
    # prompt = string.Template(get_prompt_for_title_extraction()).safe_substitute(mapping={})
    # Maybe add some tips on how to do this with Google Cloud Console Language Studio so that people can experiment 
    # there with the content? 
    prompt = """
        Extract the title from the following text delimited by triple backquotes.

        ```{text}```

        TITLE:
    """
    response = model.predict(prompt.format(text=text[:10000]))
    return response.text


def pages(text: str, batch_size: int) -> str:
    it = iter(text)
    while batch := tuple(islice(it, batch_size)):
        yield "".join(batch)


def extract_summary_from_text(text: str) -> str:
    model = TextGenerationModel.from_pretrained("text-bison@latest")
    # Similar to extract title, let people fill in the prompts & mapping only? Or do we let them come up with
    # this split of initial vs final prompt?
    final_prompt_template = """
        Write a concise summary of the following text delimited by triple backquotes.

        ```{text}```

        SUMMARY:
    """
    initial_prompt_template = """
        Taking the following context delimited by triple backquotes into consideration:

        ```{context}```

        Write a concise summary of the following text delimited by triple backquotes.

        ```{text}```

        CONCISE SUMMARY:
    """
    summaries = ""
    context = ""
    for page in pages(text, 16000):
        prompt = initial_prompt_template.format(context=context, text=page)
        print("Sub prompt length:", len(prompt))
        context = model.predict(prompt).text
        summaries += f"\n{context}"
    prompt = final_prompt_template.format(text=summaries)
    print("Final prompt length:", len(prompt))
    return model.predict(prompt).text   


def store_results_in_bq(dataset: str, table: str, **kwargs) -> Sequence:
    client = bigquery.Client(project=PROJECT_ID)
    table_uri = f"{dataset}.{table}"

    rows_to_insert = [kwargs]

    errors = client.insert_rows_json(
        table_uri, rows_to_insert, row_ids=bigquery.AutoRowIDs.GENERATE_UUID
    )
    return errors


def on_document_added(event, context):
    pubsub_message = json.loads(base64.b64decode(event["data"]).decode("utf-8"))
    src_bucket = pubsub_message["bucket"]
    src_fname = pubsub_message["name"]
    print("File:", src_fname)

    dst_bucket = STAGING_BUCKET
    dst_folder = extract_text_from_document(src_bucket, src_fname, dst_bucket)
    print("Completed the text extraction")

    complete_text = collate_pages(dst_bucket, dst_folder)
    print("Completed collation, #characters:", len(complete_text))

    title = extract_title_from_text(complete_text)
    print("Title:", title)

    summary = extract_summary_from_text(complete_text)
    print("Summary:", summary)

    if title and summary:
        errors = store_results_in_bq(
            dataset=BQ_DATASET,
            table=BQ_TABLE,
            uri=f"gs://{src_bucket}/{src_fname}", 
            name=src_fname, 
            title=title, 
            summary=summary)
        if errors:
            print("Errors:", errors)