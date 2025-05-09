# Genkit AI Monitoring

## Introduction

Welcome to the coach's guide for The IoT Hack of the Century gHack. Here you will find links to specific guidance for coaches for each of the challenges.

> **Note** If you are a gHacks participant, this is the answer guide. Don't cheat yourself by looking at this guide during the hack!

## Coach's Guides

- Challenge 1: Set up your environment and interact with the app
- Challenge 2: Explore Monitoring dashboard
- Challenge 3: Troubleshoot failures
- Challenge 4: Improve performance
- Challenge 5: Improve search quality

## Suggested Hack Agenda

- Day 1
  - Challenge 1 (~20 minutes)
  - Challenge 2 (~20 minutes)
  - Challenge 3 (~30 minutes)
  - Challenge 4 (~30 minutes)
  - Challenge 5 (~20 minutes)

## Challenge 1: Set up your environment and interact with the app

### Notes & Guidance

This goal of this challenge is to set up the app locally and test it out.

All studetns should execute the step **Clone the Repository and set the environment variables** in their own Cloud accounts.

There are couple of points where students may ask for your guidance:

1. After cloning the repo, ensure Google Cloud credentials are set up correctly in each student's environment. The credentials are specified within `key.json` (this is configured by the `setup_local.sh` script).
1. Please be aware that the application's performance may be slow, particularly within the Quicklab environment. We recommend that users do not concurrently interact with the same app.
1. If you encounter issues such as no response or an extremely slow response, please try submitting the query again.
1. Movie suggestions are _intentionally_ not saved. This functionality will be fixed in Challenge 2. 
1. The app's vector search functionality works best with *genre*-based (semantic) queries, which leverages its vector search capabilities to find relevant recommendations efficiently. Queries based on specific *ratings* (are not semantic) are less suited for this vector approach. For any query, the *retriever* fetches potential results. However, with *rating* queries, the vector search often retrieves many irrelevant movies that must then be filtered out by the RAG portion of the application before being displayed. This is why there are fewer *rating* based results. The students only need to notice that there are fewer *rating*-based results than *genre*-based results. They will understand the reason behind this in a later challenge.

## Challenge 2: Exploring Monitoring dashboard

### Notes & Guidance

In this challenge, users will use Firebase Genkit Monitoring to understand the reliability and performance of the app.

The dashboard can be found in the [Firebase console](https://console.firebase.google.com/) by navigating to:
Your Qwiklab project > **Product categories** (left-side panel) > **AI** > **Genkit** tab.

Here's an example of where to find it:

<img src="./images/genkit_nav.png" alt="Firebase console navigation to Genkit monitoring" width="200" height="330">

Once the metrics start trickling in, the dashboard should look similar to this:

<img src="./images/genkit_dash.png" alt="Genkit monitoring dashboard overview" width="550" height="300">

> **Note** Until the metrics come in, the **Genkit Monitoring** page might show zero state. Don't panic. Give it a few minutes and then refresh.

1. The dashboard shows three project-level metrics:
- **Requests**
- **Success Rate**
- **Latency**
The **Success Rate** dashboard might show that one feature (e.g., `userPreferenceFlow`) has a low success rate.

2. There are approximately four key features displayed in the dashboard (depending how much each student interacted with the app in Challenge 1):
- `chatFlow`
- `docSearchFlow`
- `userPreferenceFlow`
- `qualityFlow`

While `chatFlow` is a critical feature that's responsible for the main interaction, the others also require monitoring. Features can be thought of as monitoring scopes, so every independently invoked Genkit flow (orchestration) creates a new feature entry.

3. The **chatFlow** handles core user interactions. Clicking on this feature will display its individual metrics.
<img src="./images/chatFlow_dashboard.png" alt="chatFlow dashboard" width="450" height="300">

4. Individual traces will provide a detailed breakdown of a flow's execution, similar to the example below.

When a user gets recommendations, a trace might typically include the following steps (or spans):
- `safetyIssueFlow`
- `queryTransformFlow`
- `docSearchFlow`
- `movieQAFlow`

If no search is required for a particular query, the `docSearchFlow` span will be absent.
Each step (or span) in the trace will show its latency.
<img src="./images/chatFlow_Trace.png" alt="chatFlow trace" width="450" height="300">
 
5. By clicking on the tri-dot menu (three vertical dots) next to a trace or span, users can access related logs and traces in Google Cloud Logging and Google Cloud Trace for more in-depth observability.

## Challenge 3: Troubleshoot failures

### Notes & Guidance

In this challenge we see that the **MovieGuru** app doesn't always store the user's strong preferences when they express it (eg: I love horror movies, I hate drama films etc).

To see how preference saving is expected to work, watch this video:

[![Movie Guru](https://img.youtube.com/vi/l_KhN3RJ8qA/0.jpg)](https://youtu.be/l_KhN3RJ8qA)

1. The participants should interact with the app to make sure the monitoring tool captures the misbehavior. Then, the users should inspect the monitoring dashboard, looking for features with **low success rate**. Even if they haven't identified it already via Step 1 of Challenge 2, by now the participants should see that userPreferenceFlow is failing a lot. The flow is defined in  _js/flows/src/userPreferenceFlow.ts_. 

2. Participants should find a failed trace for this feature and inspect the output. They can use the **Failed paths** table (aggregates failures of the same nature in a feature) to understand the impact and help filter to failing traces. In this case all interaction with userPreferencesFlow result in failures, so finding a failed trace does not require using the "Failed paths" table. They can simply look at the latest trace in the traces table below. The dashboard should look like the following:

<img src="./images/userPreferencesFlow_failedPaths.png" alt="userPreferencesFlow Failed Traces" width="450" height="300">

Clicking on a individual failed trace shows more details about the error: 

<img src="./images/userPreferencesFlow_error.png" alt="userPreferencesFlow Error" width="450" height="300">

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

3. The error is a _type mismatch error_. This indicates a discrepancy between the data structure the _userPreferenceFlow_ expects to receive from the model, and the structure the model is _actually_ producing based on the prompt's instructiSons. 

4. The app is currently using the experimental prompt (_js/flows/prompts/userPreference.experimental.prompt_). This prompt has an error as it provides conficting information. In the prompt text, it asks the model to return a list of items of type **string**, while the Flow expects a list of items of type **profileChangeRecommendations**.

