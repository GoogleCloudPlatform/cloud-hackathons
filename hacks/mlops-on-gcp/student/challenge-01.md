# Challenge 1: Let’s start exploring!

**[Home](../README.md)** - [Next Challenge >](challenge-02.md)

## Introduction

As depicted in the overview diagram, the first step of any ML project is data analysis and maybe some experimentation. Jupyter notebooks are great for interactive exploration. We can run those locally, but Vertex AI provides managed environments where you get to run Jupyter with the right security controls.

## Description 

Create a Managed Notebook on Vertex AI. It's a good practice to have isolated virtual environments for experiments, so create a new virtual environment and install that as a kernel. See this [gist](https://gist.github.com/meken/e6c7430997de9b3f2cf7721f8ecffc04) for the instructions. 

We’ve prepared a [sample project on Github](https://github.com/meken/gcp-mlops-demo/archive/refs/heads/main.zip), navigate there and download the project as a **zip** file and extract the contents of the zip file into your notebook environment. Open the notebook `01-tip-toe-vertex-ai.ipynb`, make sure that you've selected the newly created kernel. You should now be able to run the first notebook and get familiar with some of the Vertex AI concepts.

<ql-warningbox>
Unfortunately at the moment it's not possible to create Managed Notebooks in Qwiklab environments. For this lab you can use _User-Managed Notebooks_. Pick a region close to you, create a simple vanilla Python3 notebook instance (with no GPUs) and please make sure that you've selected the **single user only** mode for the permissions. 
</ql-warningbox>

## Success Criteria

1. There’s a new (User-)Managed Notebook
2. The sample notebook `01-tip-toe-vertex-ai.ipynb` is successfully run and a model file is generated/stored in Google Cloud Storage
3. No code changes are needed for this challenge

## Tips

- Some of the required settings can be found in the _Advanced Settings_ section when you're creating a new _User-Managed Notebook_.
- You can download the zip file to your local machine and then upload it to the Notebook, but you can also get the zip URL and use the `wget` (or `curl`) command from the notebook environment.
- Not using a dedicated and isolated environment/kernel might cause dependency conflicts as _User-Managed Notebook_ instances come pre-installed with some versions of the required libraries.

## Learning Resources

- Documentation on [Vertex AI Workbench](https://cloud.google.com/vertex-ai/docs/workbench/managed/introduction)

