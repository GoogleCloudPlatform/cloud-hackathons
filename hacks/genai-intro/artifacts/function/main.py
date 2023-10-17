import base64
import json
import os
import string

from itertools import islice

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
    # TODO provide the prompt, you can use {} references for substitution, don't forget to configure the mapping
    # See https://docs.python.org/3/library/stdtypes.html#str.format
    return ""


def extract_title_from_text(text: str) -> str:
    vertexai.init(project=PROJECT_ID, location="us-central1")  # PaLM only available in us for now
    model = TextGenerationModel.from_pretrained("text-bison@latest")
    prompt = get_prompt_for_title_extraction()

    if not prompt:
        return ""  # return empty title for empty prompt

    response = model.predict(prompt.format())  # TODO pass references to format
    return response.text


def pages(text: str, batch_size: int) -> str:
    it = iter(text)
    while batch := tuple(islice(it, batch_size)):
        yield "".join(batch)


def get_prompt_for_summary_1() -> str:
    # TODO provide the prompt, you can use {} references for substitution, don't forget to configure the mapping
    # See https://docs.python.org/3/library/stdtypes.html#str.format
    return ""


def get_prompt_for_summary_2() -> str:
    # TODO provide the prompt, you can use {} references for substitution, don't forget to configure the mapping
    # See https://docs.python.org/3/library/stdtypes.html#str.format
    return ""


def extract_summary_from_text(text: str) -> str:
    model = TextGenerationModel.from_pretrained("text-bison@latest")
    rolling_prompt_template = get_prompt_for_summary_1()
    final_prompt_template = get_prompt_for_summary_2()

    if not rolling_prompt_template or not final_prompt_template:
        return ""  # return empty summary for empty prompts

    context = ""
    summaries = ""
    for page in pages(text, 16000):
        prompt = rolling_prompt_template.format()  # TODO pass references to format
        context = model.predict(prompt, max_output_tokens=256).text
        summaries += f"\n{context}"
    
    prompt = final_prompt_template.format()  # TODO pass references to format
    return model.predict(prompt, max_output_tokens=256).text


def store_results_in_bq(dataset: str, table: str, columns: dict[str, str]) -> bool:
    client = bigquery.Client(project=PROJECT_ID)
    table_uri = f"{dataset}.{table}"

    rows_to_insert = [columns]

    errors = client.insert_rows_json(
        table_uri, rows_to_insert, row_ids=bigquery.AutoRowIDs.GENERATE_UUID
    )

    if errors:
        print("Errors while storing data in BQ:", errors)
    
    return not errors


def on_document_added(event, context):
    pubsub_message = json.loads(base64.b64decode(event["data"]).decode("utf-8"))
    src_bucket = pubsub_message["bucket"]
    src_fname = pubsub_message["name"]
    print("Processing file:", src_fname)

    dst_bucket = STAGING_BUCKET
    dst_folder = extract_text_from_document(src_bucket, src_fname, dst_bucket)
    print("Completed the text extraction")

    complete_text = collate_pages(dst_bucket, dst_folder)
    print("Completed collation, #characters:", len(complete_text))

    title = extract_title_from_text(complete_text)
    print("Title:", title)

    summary = extract_summary_from_text(complete_text)
    print("Summary:", summary)

    # TODO uncomment the next two lines for the last challenge
    # columns = {"uri": f"gs://{src_bucket}/{src_fname}", "name": src_fname, "title": title, "summary": summary}
    # store_results_in_bq(dataset=BQ_DATASET, table=BQ_TABLE, columns=columns)
