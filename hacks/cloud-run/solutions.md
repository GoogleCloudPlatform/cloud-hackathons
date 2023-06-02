# Cloud Run in a Speed Run

## Introduction

Welcome to the coach's guide for the *Cloud Run in a Speed Run* hack. Here you will find links to specific guidance for coaches for each of the challenges.

> **Note** If you are a gHacks participant, this is the answer guide. Don't cheat yourself by looking at this guide during the hack!

## Coach's Guides

- Challenge 1: Building and deploying a web service
- Challenge 2: A faster feedback loop
- Challenge 3: Logging and Monitoring
- Challenge 4: Firestore
- Challenge 5: Cloud SQL
- Challenge 6: Keeping secrets safe
- Challenge 7: Memorystore

## Challenge 1: Building and deploying a web service

### Notes & Guidance

If participants have chosen to work from their local environments (instead of Cloud Shell), it's recommended to create a new configuration for gcloud. They'll also have to install all the prerequisites to be able to complete the challenges.

> **Note**  
> The easiest option is to use Cloud Shell as it has everything that's needed, it will provide a smooth experience. The only downside of using Cloud Shell is that the participants won't typically use Cloud Shell in their day-to-day workflow.

You can download and upload the zip file to Cloud Shell through the UI, but it's easier to use `wget`. 

```shell
wget https://github.com/meken/speedrun/archive/refs/heads/main.zip
```

It's also allowed to do a `git clone` if they manage to find the repository on Github.

After unpacking the zip file, you need to change directory to the `service` directory and install the dependencies.

```shell
cd speedrun-main/service  # assuming that the zip file is used
npm install
```

You can start the application by running the following command in the same directory

```shell
npm start
```

The app should be available on `http://localhost:8080`. 

The *Team Name* in the welcome message can be configured in `service/routes/index.js` file.

In order to deploy the app to Cloud Run, use the following command, while still in `service` directory (you can omit the `--source` flag as it's the default).

```shell
gcloud run deploy my-first-app --source .
```

In order to run the tests change directory to the top level `test` directory and install the dependencies there first.

```shell
cd ../test   # assuming that you were in service directory
npm install 
```

Once the dependencies are installed, you can run the tests from that directory.

```shell
npm run test ./run.test.js  # while in the test directory
```

You should see something like this:

![Running tests](images/running-tests.gif)

## Challenge 2: A faster feedback loop

### Notes & Guidance

## Challenge 3: Logging and Monitoring

### Notes & Guidance

## Challenge 4: Firestore

### Notes & Guidance

## Challenge 5: Cloud SQL

### Notes & Guidance

## Challenge 6: Keeping secrets safe

### Notes & Guidance

## Challenge 7: Memorystore

### Notes & Guidance

