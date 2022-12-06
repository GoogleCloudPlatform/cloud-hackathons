# Challenge 1: Let’s start exploring!

**[Home](./README.md)** - [Next Challenge >](solution-02.md)

## Notes & Guidance

For Qwiklabs users the only option is User-Managed Notebooks as the Managed Notebooks option is not available. 

The Notebook can run anywhere, but a region close to the participants is preferred. For User-Managed Notebooks, a vanilla Python image is faster than the other options, so that should be chosen. And the _Permissions_&rarr;_Single user only_ option must be chosen (which is the default for Managed Notebooks), which requires to enter the Advanced Setting section for User-Managed Notebooks.

Creating a virtual environment is essential otherwise things might break due to dependency conflicts. The instructions point to a gist that works with `conda` and both standard and User-Managed Notebooks have that installed. However Managed Notebooks might require a different approach; participants can use `pip` virtual environments.

```shell
python3 -m venv .playground
source .playground/bin/activate
```

The easiest way to get the zip file is through `curl` or `wget`. But download & upload is also fine.

```shell
curl -JLO https://github.com/meken/gcp-mlops-demo/archive/refs/heads/main.zip
```

Once the archive is extracted, the notebook should be opened and the cells must be executed one by one. Note that restarting the kernel takes a few moments, users need to wait for it before continuing with the next steps. 

No changes are needed for the notebook, the GCS bucket is created by default in the selected region `us-central1`. No need to change that. But if users change that, they need to make sure that the new region is also used in other challenges.

