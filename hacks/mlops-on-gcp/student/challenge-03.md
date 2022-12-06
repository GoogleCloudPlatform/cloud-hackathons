
[< Previous Challenge](challenge-02.md) - **[Home](../README.md)** - [Next Challenge >](challenge-04.md)
## Introduction

This task is all about automating things using Cloud Build.

## Description

Once things look fine locally, set up a Cloud Build that’s triggered when code is pushed to the repository. The code base already includes a build configuration (`cloudbuild.yaml`), have a look at it to understand what it does. Make sure that the trigger uses that build configuration. 

## Success Criteria

1. There’s a new Cloud Build push trigger
2. The trigger is connected to the repository created in the previous task
3. The trigger uses the provided (fully configured) build configuration from the repository
4. And there’s at least one successful build 

## Tips

- You will need to make some minor changes to the code base to have a successful run

## Learning Resources

How-to guides for [Cloud Build](https://cloud.google.com/build/docs/how-to)

