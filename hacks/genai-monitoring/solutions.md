# Genkit AI Monitoring

## Introduction

Welcome to the coach's guide for The IoT Hack of the Century gHack. Here you will find links to specific guidance for coaches for each of the challenges.

Remember that this hack includes a optional [lecture presentation](resources/lecture.pdf) that features short presentations to introduce key topics associated with each challenge. It is recommended that the host present each short presentation before attendees kick off that challenge.

> **Note** If you are a gHacks participant, this is the answer guide. Don't cheat yourself by looking at this guide during the hack!

## Coach's Guides

- Challenge 1: Set up your environment and interact with the app
- Challenge 2: Exploring Monitoring dashboard
- Challenge 3: Troubleshooting failures
- Challenge 4: Improving performance

## Coach Prerequisites

This hack has prerequisites that a coach is responsible for understanding and/or setting up BEFORE hosting an event. Please review the [gHacks Hosting Guide](https://ghacks.dev/faq/howto-host-hack.html) for information on how to host a hack event.

The guide covers the common preparation steps a coach needs to do before any gHacks event, including how to properly setup Google Meet and Chat Spaces.

### Student Resources

Before the hack, it is the Coach's responsibility create and make available needed resources including:

- Files for students
- Lecture presentation
- Terraform scripts for setup (if running in the customer's own environment)

Follow [these instructions](https://ghacks.dev/faq/howto-host-hack.html#making-resources-available) to create the zip files needed and upload them to your gHack's Google Space's Files area.

Always refer students to the [gHacks website](https://ghacks.dev) for the student guide: [https://ghacks.dev](https://ghacks.dev)

> **Note** Students should **NOT** be given a link to the gHacks Github repo before or during a hack. The student guide intentionally does **NOT** have any links to the Coach's guide or the GitHub repo.

### Additional Coach Prerequisites (Optional)

_Please list any additional pre-event setup steps a coach would be required to set up such as, creating or hosting a shared dataset, or preparing external resources._

## Google Cloud Requirements

This hack requires students to have access to Google Cloud project where they can create and consume Google Cloud resources. These requirements should be shared with a stakeholder in the organization that will be providing the Google Cloud project that will be used by the students.

_Please list Google Cloud project requirements._

_For example:_

- Google Cloud resources that will be consumed by a student implementing the hack's challenges
- Google Cloud permissions required by a student to complete the hack's challenges.


## Repository Contents

_The default files & folders are listed below. You may add to this if you want to specify what is in additional sub-folders you may add._

- `README.md`
  - Student's Challenge Guide
- `solutions.md`
  - Coach's Guide and related files
- `./resources`
  - Resource files, sample code, scripts, etc meant to be provided to students. (Must be packaged up by the coach and provided to students at start of event)
- `./artifacts`
  - Terraform scripts and other files needed to set up the environment for the gHack
- `./images`
  - Images and screenshots used in the Student or Coach's Guide

## Environment

- Setting Up the Environment (if not on Qwiklabs)
  - Before we can hack, you will need to set up a few things.
  - Run the instructions on our [Environment Setup](../../faq/howto-setup-environment.md) page.

## Challenge 1: Set up your environment and interact with the app

### Notes & Guidance

This goal of this challenge is to set up the app locally and test it out.

All studetns should execute the step **Clone the Repository and set the environment variables** in their own cloud accounts.

There are couple of points where things *may* go wrong:

1. Ensure your Google Cloud credentials are set up correctly in your local environment. This typically involves having a `key.json` file configured. (This is configured by the `setup_local.sh` script).
1. Please be aware that the application's performance may be slow, particularly within the Quicklab environment. We recommend that users do not concurrently interact with the app.
1. If you encounter issues such as no response or extremely slow responses, please try submitting your query again.
1. The app's vector search functionality works best with *genre*-based (semantic) queries, which leverage its vector search capabilities to find relevant recommendations efficiently. Queries based on specific *ratings* (are not semantic) are less suited for this vector approach. For any query, the *retriever* fetches potential results; however, with *rating* queries, the vector search often retrieves many irrelevant movies that must then be filtered out by the RAG portion of the application before being displayed. This is why there are fewer *rating* based results. The students only need to notice that there are fewer *rating*-based results than *genre*-based results. They will realise the reason behind this in a later challenge.

## Challenge 2: Exploring Monitoring dashboard

### Notes & Guidance

In this challenge, users will use the Firebase Genkit monitoring dashboard to understand the reliability and performance of the app.

The Genkit monitoring dashboard can be found in the [Firebase console](https://console.firebase.google.com/) by navigating to:
Your Qwiklab project > **Product categories** (sidebar) > **AI** > **Genkit** tab.

Here's an example of where to find it:
![Firebase console navigation to Genkit monitoring](./images/genkit_monitoring.png)

Once the metrics start trickling in, the dashboard should look similar to this:
![Genkit monitoring dashboard overview](./images/genkit_dash.png)

> **Note** Until the metrics come in, the **Genkit Monitoring** page might look like a documentation page without any dashboards. Don't panic. Give it a few minutes and refresh.

Users might notice three main dashboards:
- **Requests**
- **Success Rate**
- **Latency**
The **Success Rate** dashboard might show that one feature (e.g., `UserProfileFlow`) has a low success rate.

There are approximately four key features displayed in the dashboard:
- `chatFlow`
- `docSearchFlow`
- `userPreferenceFlow`
- `qualityFlow`
While `chatFlow` is a critical feature, the others also require monitoring. Features can be thought of as monitoring scopes, so every independently invoked Genkit flow (orchestration) creates a new feature entry.

The **chatFlow** handles core user interactions. Clicking on this feature will display individual metrics for that specific flow.
!chatFlow Dashboard

Individual traces will provide a detailed breakdown of a flow's execution, similar to the example below.

When a user gets recommendations, a trace might typically include the following steps (or spans):
- `safetyIssueFlow`
- `queryTransformFlow`
- `docSearchFlow`
- `movieQAFlow`
If no search is required for a particular query, the `docSearchFlow` span will be absent.
Each step (or span) in the trace will show its latency.
 !chatFlow Trace
 
 By clicking on the tri-dot menu (three vertical dots) next to a trace or span, users can access related logs and traces in Google Cloud Logging and Google Cloud Trace for more in-depth observability.

## Challenge 3: Troubleshoot failures

### Notes & Guidance

In this challenge we see that the **MovieGuru** app doesn't always store the user's strong preferences when they express it (eg: I love horror movies, I hate drama films etc).

To see how preference saving is expected to work, watch this video:

[![Movie Guru](https://img.youtube.com/vi/l_KhN3RJ8qA/0.jpg)](https://youtu.be/l_KhN3RJ8qA)

The user's need to identify that the flow that has issues is the userPreferencesFlow defined in  _js/flows/src/userPreferenceFlow.ts_. 

The user's will see the following error message if they inspect a failed trace in the dashboard. Users can use the **failed paths** table (aggregates failures of the same nature in a feature) to find the reason. The dashboard should look like the following.

![UserPreferencesFlow Failed Traces](./images/userPreferencesFlow_failedPaths.png)

Clicking on a individual failed trace also shows the error. 

![UserPreferencesFlow Error](./images/userPreferencesFlow_error.png)

```
ZodError: [
  {
    "code": "unrecognized_keys",
    "keys": [
      "justification",
      "safetyIssue",
      "items"
    ],
    "path": [],
    "message": "Unrecognized key(s) in object: 'justification', 'safetyIssue', 'items'"
  }
]
```

The error is a _type mismatch error_. This indicates a discrepancy between the data structure the _userPreferenceFlow_ expects to receive from the model, and the structure the model is _actually_ producing based on the prompt's instructiSons. 

The app is currently using the experimental prompt (_js/flows/prompts/userPreference.experimental.prompt_). This prompt has an error as it provides conficting information. In the prompt text, it asks the model to return a list of items of type **string**, while the Flow expects a list of items of type **profileChangeRecommendations**

```

