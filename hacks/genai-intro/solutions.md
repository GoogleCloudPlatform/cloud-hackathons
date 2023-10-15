# Practical GenAI

## Introduction


## Coach's Guides

- Challenge 1: 
- Challenge 2: 
- Challenge 3: 
- Challenge 4: 

## Challenge 1:

### Notes & Guidance

Create the buckets, on Cloud Shell the variable `$GOOGLE_CLOUD_PROJECT` contains the project id.

```shell
REGION="us"  # LLMs only available in US, although buckets could be anywhere
BUCKET="gs://$GOOGLE_CLOUD_PROJECT-documents"
STAGING="gs://$GOOGLE_CLOUD_PROJECT-staging"

gsutil mb -l $REGION $BUCKET
gsutil mb -l $REGION $STAGING
```

```shell
TOPIC=documents
gcloud storage buckets notifications create --event-types=OBJECT_FINALIZE --topic=$TOPIC $BUCKET
```


## Challenge 2:

### Notes & Guidance


## Challenge 3:

### Notes & Guidance

Any region can be selected to do the build (with Qwiklabs you might need to choose the global option). Users need to point to the right build file, and that's `/build/cloudbuild.yaml`, note the `/build/` prefix.

There's trailing whitespace in one of the files, which causes the linter to fail. That needs to be removed, and when the changes are pushed, the push trigger will yield a succesfull build.

## Challenge 4:

### Notes & Guidance

