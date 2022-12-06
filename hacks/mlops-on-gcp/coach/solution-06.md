# Challenge 6: Monitor your models

[< Previous Challenge](solution-05.md) - **[Home](./README.md)** - [Next Challenge >](solution-07.md)

## Notes & Guidance

Once the Endpoint is up and running, it's possible to edit it from the UI and turn on Monitoring. Alternatively the following `gcloud` command can be used (this command also enabled Cloud Logging which is at the moment not possible through the UI).

```shell
REGION=...
PROJECT_ID=...
ENDPOINT_ID=...
gcloud ai model-monitoring-jobs create --region=$REGION \
    --display-name=monitor_this \
    --endpoint=$ENDPOINT_ID \
    --prediction-sampling-rate=0.2 \
    --target-field=tip_bin \
    --data-format=csv \
    --gcs-uris=gs://$PROJECT_ID/data/sample/sample.csv \
    --anomaly-cloud-logging \
    --monitoring-frequency=1 \
    --emails=student@qwiklabs.net \
    --feature-thresholds=trip_month,trip_day,trip_day_of_week,trip_hour,trip_duration,trip_distance,payment_type,pickup_zone,dropoff_zone 
```

