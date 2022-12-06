
[< Previous Challenge](challenge-03.md) - **[Home](../README.md)** - [Next Challenge >](challenge-05.md)
## Introduction

The previous challenge introduced the concept of build pipelines. But there are different types of pipelines, and this task is getting started with Vertex AI pipelines for continuous training. 

## Description

If you’ve successfully completed the previous challenge, your training code has been packaged and can be run from a pipeline.

The provided project has a `pipeline.py` file that can generate a pipeline definition. Run that to generate a pipeline definition file (JSON). Use the generated pipeline definition file to create a new Pipeline Run through the GCP Console. You'll need to fill in some parameters (you can look up the Python package location). Do not set/override the endpoint and monitoring_job parameters (keep the default values).

<ql-infobox>
Once the pipeline is triggered, it will take ~10 minutes to complete.
</ql-infobox>

## Success Criteria

1. There’s at least one successful Vertex AI pipeline run that has generated a Managed Model in the Model Registry
2. No code change is needed for this challenge

## Tips

- You have already created a bucket, you can use that as the pipeline root (optionally add `pipelines` folder in it).
- Make sure that you're consistent in your region selection.
- You can either upload the pipeline definition from a local machine, or put it on GCS and refer to its location.
- Make sure that you're running the module `trainer.pipeline` in the virtual environment you have created as part of the first challenge.
- If you're in doubt about the parameters, remember to _Use the Force and read the Source_ ;)

## Learning Resources

- Running [Python modules from the command line](https://docs.python.org/3/using/cmdline.html#cmdoption-m)
- Running [Vertex AI Pipelines](https://cloud.google.com/vertex-ai/docs/pipelines/run-pipeline#console) on the console

