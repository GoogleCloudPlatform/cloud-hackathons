# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
import base64
import json
import os

from itertools import islice
from typing import Iterator

import vertexai

from google.cloud import bigquery
from google.cloud import storage
from google.cloud import vision

from vertexai.generative_models import GenerativeModel


PROJECT_ID=os.getenv("GCP_PROJECT_ID")
REGION=os.getenv("GCP_REGION")
STAGING_BUCKET=f"{PROJECT_ID}-staging"

BQ_DATASET="articles"
BQ_TABLE="summaries"

MODEL_NAME="gemini-1.5-flash-001"

vertexai.init(project=PROJECT_ID, location=REGION)


def extract_text_from_document(src_bucket: str, file_name: str, dst_bucket: str) -> str:
    """Extracts the contents of the PDF document and stores the results in a folder in GCS.

    In order to extract the contents of the PDF document OCR is applied and the results, 
    consisting of JSON files, are stored in the destination bucket in a folder that has 
    the same name as the source file name.

    Do not edit.

    Args:
        src_bucket: source bucket without the gs prefix, e.g. my-uploaded-docs-bucket
        file_name: source file name, e.g. my-file.pdf
        dst_bucket: destination bucket without the gs prefix, e.g. my-staging-bucket

    Returns:
        destination folder, name of the folder in the staging bucket where the JSON 
        files are stored for the PDF document
    """
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
    """Collates all pages, stored as JSON files in the provided bucket & folder, 
    parses them, extracts the relevant parts and concatenates them into a single string.

    Do not edit.

    Args:
        bucket: bucket without the gs prefix, e.g. my-staging-bucket
        folder: folder name, e.g. my-file/

    Returns:
        complete text of the PDF document as a single string in regular text format
    """
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
    """Returns a prompt for title extraction. 
    
    To be modified for Challenge 2.

    Returns:
        prompt for title extraction, with placeholders for substitution
    """
    # TODO Challenge 2, provide the prompt, you can use {} references for substitution
    # See https://www.w3schools.com/python/ref_string_format.asp
    return ""


def extract_title_from_text(text: str) -> str:
    """Given the full text of the PDF document, extracts the title.

    To be modified for Challenge 2.

    Args:
        text: full text of the PDF document

    Returns:
        title of the PDF document
    """
    model = GenerativeModel(MODEL_NAME)
    prompt_template = get_prompt_for_title_extraction()
    prompt = prompt_template.format() # TODO Challenge 2, set placeholder values in format

    if not prompt:
        return ""  # return empty title for empty prompt
    
    if model.count_tokens(prompt).total_tokens > 2500:
        raise ValueError("Too many tokens used")

    response = model.generate_content(prompt)
    return response.text


def pages(text: str, batch_size: int) -> Iterator[str]:
    """Yield successive n-sized chunks from text.

    Do not edit.

    Args:
        text: full text of the PDF document
        batch_size: size of the chunks

    Yields:
        successive n-sized chunks of text
    """
    it = iter(text)
    while batch := tuple(islice(it, batch_size)):
        yield "".join(batch)


def get_prompt_for_page_summary_with_context() -> str:
    """Returns a prompt for the page summary with context. 
    
    To be modified for Challenge 3.

    Returns:
        prompt for page summary with context, with placeholders for substitution
    """
    # TODO Challenge 3, provide the prompt, you can use {} references for substitution
    # See https://www.w3schools.com/python/ref_string_format.asp
    return ""


def extract_summary_from_text(text: str) -> str:
    """Given the full text of the PDF document, extracts the summary.

    To be modified for Challenge 3.

    Args:
        text: full text of the PDF document

    Returns:
        summary of the PDF document
    """
    model = GenerativeModel(MODEL_NAME)
    rolling_prompt_template = get_prompt_for_page_summary_with_context()

    if not rolling_prompt_template:
        return ""  # return empty summary for empty prompts

    summary = ""
    for page in pages(text, 16000):
        prompt = rolling_prompt_template.format()  # TODO Challenge 3, set placeholder values in format
        summary = model.generate_content(prompt).text
    
    return summary


def store_results_in_bq(dataset: str, table: str, columns: dict[str, str]) -> bool:
    """Stores the results of title extraction and summary generation in BigQuery.

    Do not edit.
    
    Args:
        dataset: the name of the BigQuery dataset
        table: the name of the BigQuery table where the results will be stored
        columns: a dictionary of columns and their values

    Returns:
        True if successful, False otherwise (if there were any errors)
    """
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
    """Triggered from a message on a Cloud Pub/Sub topic.

    Do not edit until Challenge 4.

    Args:
        event: event payload
        context: metadata for the event.
    """
    pubsub_message = json.loads(base64.b64decode(event["data"]).decode("utf-8"))
    src_bucket = pubsub_message["bucket"]
    src_fname = pubsub_message["name"]
    print("Processing file:", src_fname)

    if pubsub_message["contentType"] != "application/pdf":
        raise ValueError("Only PDF files are supported, aborting")

    dst_bucket = STAGING_BUCKET
    dst_folder = extract_text_from_document(src_bucket, src_fname, dst_bucket)
    print("Completed the text extraction")

    complete_text = collate_pages(dst_bucket, dst_folder)
    print("Completed collation, #characters:", len(complete_text))

    title = extract_title_from_text(complete_text)
    print("Title:", title)

    summary = extract_summary_from_text(complete_text)
    print("Summary:", summary)

    # TODO Challenge 4, uncomment the next two lines
    # columns = {"uri": f"gs://{src_bucket}/{src_fname}", "name": src_fname, "title": title, "summary": summary}
    # store_results_in_bq(dataset=BQ_DATASET, table=BQ_TABLE, columns=columns)
