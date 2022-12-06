# Challenge 4: Automagic training with pipelines

[< Previous Challenge](solution-03.md) - **[Home](./README.md)** - [Next Challenge >](solution-05.md)

## Notes & Guidance

The `pipeline` module can be used to generate the pipeline definition. Assuming that the user is in the right environment:

```shell
python -m trainer.pipeline
```

The generated json file can be copied to the default GCS bucket (created as part of the first challenge) or downloaded locally.

The parameters for the Vertex AI Pipeline Job:

| GCS output directory | `gs://{QWIKLAB_PROJECT_ID}/pipelines`|
| endpoint             | `[none]`  |
| location             | `us-central1` |
| project\_id          | `QWIKLAB_PROJECT_ID`|
| python\_pkg          | `gcp-mlops-demo-0.8.0.dev0.tar.gz`|

The `python_pkg` parameter can also be the full path to the package, and also works without the `tar.gz` extension. `GCS output directory` could also be any folder in the bucket (no trailing `/` characters though).

