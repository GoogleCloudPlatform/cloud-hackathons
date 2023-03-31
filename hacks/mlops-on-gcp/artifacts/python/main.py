import os

from datetime import datetime
from datetime import timedelta

import functions_framework

from google.cloud import aiplatform_v1beta1
from google.cloud import datastore
from google.cloud import pubsub_v1

GCP_PROJECT_ID = os.environ.get("GCP_PROJECT_ID")
GCP_REGION = os.environ.get("GCP_REGION")
PUBSUB_TOPIC_ID = os.environ.get("PUBSUB_TOPIC_ID")

aip_client = aiplatform_v1beta1.JobServiceClient(client_options={
    "api_endpoint": f"{GCP_REGION}-aiplatform.googleapis.com"
})

ds_client = datastore.Client()

pub_client = pubsub_v1.PublisherClient()

@functions_framework.http
def scan_batch_predictions(request):
    yesterday = datetime.utcnow() - timedelta(days=1)
    filter_expr = f'state=JOB_STATE_SUCCEEDED AND create_time > "{yesterday.isoformat()}Z"'
    req = aiplatform_v1beta1.ListBatchPredictionJobsRequest(
        parent=f"projects/{GCP_PROJECT_ID}/locations/{GCP_REGION}", filter=filter_expr)
    res = aip_client.list_batch_prediction_jobs(req)

    jobs = {}
    for job in res:
        jobs[job.name] = job

    ds_client = datastore.Client()
    query = ds_client.query(kind="Job")
    query.add_filter("create_time", ">", yesterday)
    names = [e.key.name for e in query.fetch()]

    diff = jobs.keys() - set(names)
    topic = pub_client.topic_path(GCP_PROJECT_ID, PUBSUB_TOPIC_ID)
    cnt = 0
    for name in diff:
        if jobs[name].model_monitoring_status.message == "RUNNING":
            continue
        key = ds_client.key("Job", name)
        entity = datastore.Entity(key=key)
        anomaly_count = jobs[name].model_monitoring_stats_anomalies[0].anomaly_count if \
            len(jobs[name].model_monitoring_stats_anomalies) > 0 else 0
        entity.update({
            "monitoring": jobs[name].model_monitoring_status.message != "",
            "anomaly_count": anomaly_count,
            "create_time": jobs[name].create_time
        })

        if anomaly_count > 0:
            res = pub_client.publish(topic, name.encode("utf-8"))
            print(f"Message sent: {res.result()} for {name}")
        ds_client.put(entity)
        cnt += 1
    return str(cnt)