# Challenge 5: Make it work and make it scale

[< Previous Challenge](solution-04.md) - **[Home](../README.md)** - [Next Challenge >](solution-06.md)

## Notes & Guidance

Once the model is deployed the following request payload can be used to verify things. 

```json
{
    "instances": [
        [7,11,4,6,44,0,1,193,193],
        [7,25,4,23,1680,18.37,0,132,262]
    ]
}
```

Assuming that the payload is stored in a file `request.json` and there's only one `Endpoint` in the project.

```shell
PROJECT_ID=`gcloud config list --format="value(core.project)"`
ENDPOINT_ID=`gcloud ai endpoints list --region=us-central1 --format="value(ENDPOINT_ID)"`
REGION=... 
TOKEN=`gcloud auth print-access-token`
URL="https://${REGION}-aiplatform.googleapis.com/v1/projects/${PROJECT_ID}/locations/${REGION}/endpoints/${ENDPOINT_ID}:predict"

curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN"  -d @request.json $URL
```

The following commands will install & run apache-bench load tool.

```
sudo apt-get -y install apache2-utils
ab -n 30000 -c 100 -p request.json -T "application/json" -H "Authorization: Bearer $TOKEN" $URL
```

Managed Notebooks don't allow any installation, so in that case users should use Cloud Shell.

