# Practical SRE

Welcome to the Practical SRE (Site Reliability Engineering) Workshop! In this hands-on session, you’ll step into the role of SREs and Product Owners for the **Movie Guru** GenAI app—a cutting-edge application that helps users find movies using natural language queries powered by AI. Your mission is to ensure that Movie Guru delivers a smooth, reliable, and responsive experience for its users.

The Movie Guru app's backend is currently running in your cloud environments and has been pre-instrumented to silently generate a wealth of metrics through the use of a load generator. This means that as you work on these challenges, you’ll have access to valuable data reflecting its performance and user interactions, allowing you to make informed decisions throughout the workshop.

By the end of this workshop, you’ll have developed a comprehensive reliability framework for Movie Guru, gaining practical SRE skills that can be applied to real-world systems. 

Remember, if there is a term being used in the challenge you don't understand, there **Learning Resources** section at the bottom of the challenge probably explains it. Otherwise, there is always **Google**.

## Learning Objectives

In this hack you will learn how to:

   1. Identify User Journeys
   1. Identify your stakeholders in an organization.
   1. Design realistic SLOs
   1. Understanding metrics dashboards in Google Cloud Monitoring.
   1. Create SLOs in Google Cloud Monitoring.
   1. Creating Alerts
   1. SRE best practices

## Challenges

- Challenge 1: Your first day as SRE
- Challenge 2: Yes, there are others
- Challenge 3: SLOs: Not Just Another Acronym
- Challenge 4: Let the monitoring begin
- Challenge 5: SLOs on the dashboard
- Challenge 6: Stay alert
- Challenge 7: What's really UP, doc?

## Prerequisites

- Your own GCP project with Editor IAM role.
- Kubectl
- gcloud command line tool

## Contributors

- Manasa Kandula
- Steve McGhee

## Challenge 1: Your first day as SRE

### Prerequisites

Before we start our first day as SREs, we are going to start up metrics collection so that we have a nice load of metrics to work with in later challenges.

You'll set up and generate application metrics using Locust, a powerful load testing tool. The goal is to simulate user activity on the Movie Guru backend application, which is running on a GKE cluster. Locust is also deployed within the same cluster, and its load generator is pre-configured.

You will be provided with the address of the Locust load generator at the start of the project. It should look like this: <http://LocustIP:8089> (replace with the correct IP).

#### Step 1: Make note of the 3 IP addresses from your environment

- You will likely need them often, keep a note of these values and set them as environment variables.
- You might need to re-run them before running command-line commands for all challenges.
- Copy the values (after replacing the placeholders) into a notepad to be able to re-run when needed.

  ```sh
  FRONTEND_ADDRESS=<your frontend address>
  BACKEND_ADDRESS=<your backend address>
  LOCUST_ADDRESS=<your locust address>
  PROJECT_ID=<your project id>
  GKE_CONNECTION_STRING=<your GKE connection string> # Don't worry you don't need to have any GKE knowledge.

  ```

#### Step 2: Generate Load on the Application

- Open your browser and navigate to the Locust load generator address. You should see a screen similar to the one below:

   ![locust start screen](images/locust-startscreen.png)

- Fill out the *Start new load test* form with the following values:

  - Number of users at peak: 3
  - Spawn rate: 0.05
  - Host: <http://mockserver-service.movie-guru.svc.cluster.local>
  - Runtime: 7 hours (under Advanced options)
  
   This configuration will gradually increase the load on the backend, spawning around 3 simulated users over the course of 7 hours.

- Once the load test begins, Locust will swarm various backend endpoints, simulating traffic as users interact with the application. You should see something similar to this:

  ![Locust Swarming](images/locust-swarming.png)

- Confirm this is running as expected and start challenge 1.

#### [Optional] Step 3: If you are repeating Challenge 1, reset the metrics generator

> **Note**: With this command we're priming the backend that generates metrics to behave in a specific way.

Run the following in the terminal (**Cloud Shell terminal**)

```sh
## Check if the BACKEND_ADDRESS env variable is set in your environment before you do this.
curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
  "ChatSuccess": 0.7,
  "ChatSafetyIssue": 0.2,
  "ChatEngaged": 0.5,
  "ChatAcknowledged": 0.15,
  "ChatRejected": 0.25,
  "ChatUnclassified": 0.1,
  "ChatSPositive": 0.4,
  "ChatSNegative": 0.3,
  "ChatSNeutral": 0.1,
  "ChatSUnclassified": 0.2,
  "LoginSuccess": 0.99,
  "StartupSuccess": 0.75,
  "PrefUpdateSuccess": 0.84,
  "PrefGetSuccess": 0.99,
  "LoginLatencyMinMS": 10,
  "LoginLatencyMaxMS": 200,
  "ChatLatencyMinMS": 1607,
  "ChatLatencyMaxMS": 7683,
  "StartupLatencyMinMS": 456,
  "StartupLatencyMaxMS": 1634,
  "PrefGetLatencyMinMS": 153,
  "PrefGetLatencyMaxMS": 348,
  "PrefUpdateLatencyMinMS": 463,
  "PrefUpdateLatencyMaxMS": 745
}' \
$BACKEND_ADDRESS/phase 
```

### Introduction

Ok. You have started on Day 1 as the newly formed SRE team for **The Movie Advisory Company**, a start-up whose first product is the **Movie Guru** app.

### Description

This challenge involves exploring the Movie Guru app and documenting typical user journeys.

- **Access and Explore the App**

  - Go to FRONTEND_ADDRESS in your web browser.
  - Log in using your name or email. No password is required.
  - Interact with the app to understand its features:
    - Observe what happens after logging in.
    - Request movie recommendations (e.g., "I feel like watching a fantasy movie").
    - Express your preferences for genres and themes (e.g., "I love movies with funny animals," or "I dislike violent movies").
    - Check your user profile to see if the app remembers your preferences.
    - Log out and log in again to understand the app's behavior.
  
> **Warning**: AI platform rate limits in qwiklabs environments can be very low (around 10 per minute). This
    might cause the app to fail (Oops.. Something went wrong). If that is the case, then watch this video with sound turned down to understand the working of the app.

[![**Movie Guru**](https://img.youtube.com/vi/l_KhN3RJ8qA/0.jpg)](https://youtu.be/l_KhN3RJ8qA)

- **Document User Journeys**

  - Identify at least two distinct user journeys within the Movie Guru app.
  - Clearly document each journey using this format:
    - Journey Name: [Give a descriptive name]
    - Goal: [What does the user want to achieve?]
    - Steps: [List the specific actions the user takes to achieve the goal]

> **Note**: If you need a refresher on what a user journey is, visit the section on **What is a user journey?** (in **Learning Resources**).

## Success Criteria

To successfully complete this exercise, you should have:

- **Identify at least 2 user journeys:** Written down 2 UJs in the format mentioned above for the **Movie Guru** app

## Learning Resources

### What is a User Journey?

In the context of SRE (Site Reliability Engineering), a user journey (UJ) describes the series of steps a user takes to accomplish a specific goal while interacting with a service. It focuses on the user's perspective and their experience with the system's performance and reliability. It is like a map that shows the steps a user takes to achieve a goal while using our service. We use this map to understand user behavior, their expectations, and improve their experience.

Here is an example UJ for a typical online webshop:

#### Example: Adding an Item to an Online Shopping Cart

Goal: Add a desired product to their shopping cart.
Steps:

- Browse an e-commerce website.
- Find a product they want to purchase.
- Click the "Add to Cart" button.
- View the updated shopping cart with the added item.

**Compare your journeys to the examples below:**  See how your ideas align with the user journeys provided below. The examples below cover some common interactions, but there will be other ways users interact with the app. There is no perfect answer.

**User journeys are hypotheses:** They are your best guess about how users will interact with the app.  These journeys will need to be refined over time based on real user data and feedback.

## Challenge 2: Yes, there are others

Your second day as an SRE at **The Movie Advisory Company** started with a bang. The CEO, clearly fueled by an excessive amount of coffee, stormed into your workspace, ranting about Movie Guru's unreliable performance.  **"Users are complaining about the site not always being reachable!" he yelled, "This is unacceptable! Movie Guru needs to be up 100% of the time!"** He demanded a solution immediately. With a panicked look in his eyes, he pointed you towards the platform team (a single, overworked engineer) and the application team (known for their eccentric work habits).

Your challenge:  figure out how to improve the app's stability, manage the CEO's expectations, and prevent a complete meltdown.  Welcome to the world of SRE!

### Description

1. **Initial Response to CEO:** Analyze the CEO's demands in the context of SRE principles. Are there any parts of his demand that clash with those principles? Discuss your analysis with a teammate or coach. Optionally you and your team do a short role-play with one of you acting as the CEO.

   > **Note**: The focus on the role-play should be on articulating your reasoning and how it aligns with SRE principles. The focus shouldn't be on trying to persuade the CEO to change their mind (this isn't a communication/negotiation workshop).

1. **Information Gathering:** You're not alone in this quest for stability! To improve Movie Guru's stability, you'll need to collaborate with others. Identify the key stakeholders within the company and determine what information you need from each of them to achieve your reliability goals.

### Success Criteria

To successfully complete this challenge, you should be able to demonstrate the following:

**Initial Response:**

- Explained why 100% uptime is an unrealistic and potentially harmful goal.
- Clearly articulated the relationship between reliability and cost.
- Emphasized the importance of aligning reliability targets with user needs and business priorities.
- [BONUS] Communicated the need to balance reliability investments with other factors like innovation.

**Information Gathering:**

- Identified key stakeholder teams within The Movie Advisory Company (including technical teams, product owners, and business stakeholders).
- Explained the role of each stakeholder group in ensuring Movie Guru's reliability.
- Specified the information needed from each stakeholder group to assess the current state of reliability and plan for improvements.
- Demonstrated an understanding of the importance of collaboration and communication in achieving reliability goals.

### Learning Resources

By systematically identifying your stakeholders and gathering the necessary information, you gain a holistic view of Movie Guru's reliability. This sets the stage for effective improvements that balance business needs, user expectations, current system design, and technical debt—all without chasing the mirage of 100% uptime

#### Initial Response

Realistically, as an SRE, it is common for stakeholders to expect the application to deliver 100% uptime and flawless performance. However, it's essential to communicate professionally why this expectation is *unachievable* and *unnecessary*.

Understanding the inherent complexities and uncertainties in systems, we must educate stakeholders about the trade-offs involved in achieving high availability. Given that these discussions are likely to arise several times, being able to handle them with confidence and clarity is crucial.

By pushing back against unrealistic expectations, we foster a more informed dialogue, helping stakeholders appreciate the balance between ambition and practicality. Ultimately, it's our responsibility to advocate for achievable service level objectives (SLOs) that ensure both reliability and a sustainable operational model while meeting user requirements. By articulating these points fluently, we can build trust and alignment with our stakeholders while driving continuous improvement in our systems."

You have effectively addressed the CEO's demand for 100% uptime by:

- **Challenging the feasibility of 100% reliability:** You clearly explained why achieving perfect uptime is practically impossible and highlighted the exponential relationship between reliability and cost.
- **Emphasizing user needs:**  You highlighted the importance of aligning reliability targets with user expectations and business needs, rather than blindly pursuing an arbitrary number.
- **Balancing reliability with other priorities:** You emphasized the need to balance reliability investments with other crucial factors like innovation and new feature development. Overachieving on reliability (providing more than what the user expects) is also not a good thing.

**Key takeaway:**  You successfully communicated that 100% is the wrong target for everything and that a balanced approach to reliability is essential for the long-term success of Movie Guru.

#### Information Gathering

As the SRE responsible for improving Movie Guru's stability, you need to collaborate with various stakeholders within the organization. You are there to **break down silos** and not solve everthing on your own.
Remember, there's no single "right answer" to this challenge.
The goal is to encourage you to think critically about who you need to involve and what information you need to gather.

To guide your thinking, consider these two key aspects:

**Identify Key Stakeholders:**

 **Technical Teams:**
    - **Development Team:** Responsible for the application code. They can provide insights into potential bugs, performance bottlenecks, and upcoming releases.
    - **Platform Team:** Manages the underlying infrastructure (servers, databases, etc.). They can offer information about system architecture, resource allocation, potential infrastructure limitations, incident history, monitoring tools, and existing alerting mechanisms.
    - **QA Team:** (If one exists) Responsible for testing the application. They can offer insights into known issues, testing procedures, and potential areas of fragility.

 **Business and Product Stakeholders:**
    - **Product Owner/Product Manager:** Can provide crucial information about user needs and expectations regarding reliability, the product roadmap, and how stability fits into the overall business strategy.
    - **Other Business Stakeholders:** Consider departments like marketing, sales, and customer support. They can offer insights into how reliability impacts their work, provide valuable user feedback, and clarify budget constraints.

**Gather Essential Information:**

Once you've identified the key stakeholders, consider what specific information you need from each of them. This might include:

- **Current Performance Data:** Uptime history, error rates, latency metrics.
- **System Architecture Diagrams:** Visual representations of the app's components and their interactions.
- **Deployment Processes:** How new code is released and deployed to production.
- **Monitoring and Alerting:** What tools and systems are used to monitor the app's health, and what alerts are in place?
- **Incident Response Procedures:** How are incidents handled, and what are the communication channels? Also think about capacity plans, disaster recovery plans, backup/restore procedures etc.

**Collaboration is Key:** Remember that achieving reliability is a shared responsibility. Building strong relationships with these teams is essential for success.

## Challenge 3: SLOs: Not Just Another Acronym

In the previous challenge, you dove deep into Movie Guru's reliability landscape, discovering a young app with room to grow. You learned that the company currently lacks a robust way to measure and define user experience, relying instead on the unsustainable goal of constant uptime.

Armed with the insights gained from exploring the app, collaborating with stakeholders, and understanding the system's design, challenges, and user feedback, it's time to take a crucial step: defining SLIs and SLOs for User Journeys. If you need a refresher on SLIs or SLOs, see the **Learning Resources**.

### Description

**Make guesses for this exercise whenever you don't have real information to go on.**

1. **Choose Your Journeys:** Select two key user journeys for **Movie Guru**. These could be the ones you identified in Challenge 1 or the examples provided.
1. **Choose Your SLIs:** What SLIs would you use to see that your application is healthy (as experienced by the user)?
1. **Craft Your SLOs:** Define relevant SLOs for each chosen user journey using the SLIs identified above.
   - Consider what aspects of reliability matter most to users in each journey and how you can measure success.
   - See **Learning Resources** for an example.

### Success Criteria

- You have selected a subset of metrics as SLIs for your app.
- You have crafted 2 SLOs for the **Movie Guru** app. Each SLO includes the following components, demonstrating a comprehensive understanding of how to define and measure service level objectives:
  - **Objective:** A clear statement of the reliability target for a specific user journey or feature. The value has to have a good business reason behind it.
  - **Time window:** The period over which the SLI is measured (e.g., 30-day rolling window).
  - **Service Level Indicator (SLI):**  A metric used to assess the service's performance against the objective (e.g., availability, latency,  quality, throughput, timeliness). Make your best guess here.

### Learning Resources

### What are SLIs?

Service Level Indicators (SLIs) are specific measurements that show how well a service is performing. They help teams understand if they are meeting their goals for reliability and quality. For example, one SLI might measure how often a website is available to users, while another could track how quickly the website responds to requests. An SLI can also look at the number of errors or failures compared to total requests. These indicators are important because they help teams see where they can improve their services.

### What are SLOs?

Based on Google's SRE framework, Service Level Objectives (SLOs) are target values or ranges for a service's reliability, measured by Service Level Indicators (SLIs). SLOs help you define the desired user experience and guide decisions about reliability investments. They act as a key communication tool between technical teams and business stakeholders, ensuring everyone is aligned on what level of reliability is acceptable and achievable.  Crucially, SLOs should be based on what matters most to users, not arbitrary targets like 100% uptime.

Example SLO:

For the user journey of "adding a product to an online shopping cart", a possible SLO could be:

- **99.9% of "Add to Cart" requests should be successful within 2 seconds, measured over a 30-day rolling window**.
This SLO focuses on the key user action ("Add to Cart") and sets targets for both availability (99.9% success rate) and latency (2-second response time). It's directly tied to user experience, ensuring a smooth and efficient shopping experience.
The addition of "measured over a 30-day rolling window" specifies the timeframe for evaluating the SLO. This means that the success rate and response time are calculated based on data collected over the past 30 days. This rolling window provides a continuous and up-to-date assessment of the SLO's performance.

## Challenge 4: Let the monitoring begin

### Introduction

The platform team introduces you to the app's monitoring dashboards in the Google Cloud Console. They've set up four dashboards, each providing key insights into different aspects of Movie Guru's performance:

- **Login Dashboard**: Tracks the health and efficiency of the user login process.
- **Startup Dashboard**: Monitors the performance of the post-login, **Main Page Load** process, ensuring users get into the app quickly.
- **Chat Dashboard**: Provides a comprehensive view of user interactions with the chatbot, including engagement, sentiment, and response times.

> **Note**: Metrics in the dashboards may appear blocky because we’re simulating load with only a few users. Achieving smoother graphs generally requires a larger user load.

### Description

**Make guesses for this exercise whenever you don't have real information to go on.**

1. **Browse existing dashboards**
   - Navigate to **Google Cloud Monitoring \> Dashboards \> Custom Dashboards**.  
   - Examine the **Login**, **Startup**, and **Chat** dashboards.  
1. **Assess user experience**
     - Based on the metrics and your own experience (or user feedback if available), describe how users likely perceive the app's performance.  
1. **Categorize** aspects of the application into:  
    - **Going Well:** Areas with good performance.  
    - **Need Improvement:** Areas with minor performance issues.  
    - **Need Improvement Urgently:** Areas with significant performance issues impacting user experience.
1. **Choose Your SLIs:** Create 4 SLIs from metrics that are already available. 
   - Define SLIs by examining the dashboards to identify relevant metrics. In many cases, the dashboards already display key SLIs.
   - Write them down in definition form (see examples)
     - Example Availability SLI: The availability is measured by the ratio of successful startups recorded as a ratio of `metric x` to the total attempts in `metric y`.
     - Example Latency SLI: The latency, measured by the `metric x`, is tracked as a histogram at the 10th, 50th, 90th, and 99th percentiles.
   - **Tips**:
     - If you don't understand the difference between an **SLI** and a **metric** is, look at the **Learning Resources**.
     - Look at the **Business Goals** below to narrow down your search to just a few SLIs relevant for this exercise.
1. Define **Achievable** objectives for the **SLO templates** below.
    - Fill in realistic, **Achievable** values that you would like the app to meet in the short term (around 1 month). Let the current performance indicators be a guide.
1. [Optional] Define **Aspirational** SLOs (for the **SLO templates** below).
   - Imagine **Movie Guru** one year from now, a finely-tuned, user-pleasing machine (but still not perfect, because unicorns don't exist, and 100% is never the right target). It's so good that users are delighted with its performance and reliability. What would the SLOs look like in this ideal scenario? Fill those values in. These are targets that your company can work towards in the upcoming year or so.

#### SLO templates

- **Business goal 1:** The main page should be accessible and load quickly for users.

  - **SLO 1a:** `xx%` of users should successfully access the main page after logging in, measured over a `zz`-day rolling window.  

  - **SLO 1b:** `xx%` of users should access the main page after logging in within `yy` seconds, measured over a `zz`-day rolling window.

- **Business goal 2:** The chatbot should respond quickly to users and keep them engaged.

  - **SLO 2a:** `xx%` of users should be engaged by the chatbot, measured over a `zz`-hour rolling window.

  - **SLO 2b:** `xx%` of users should receive responses within `yy` seconds, measured over a `zz`-hour rolling window.

### Success Criteria

- You've chosen SLI based on the metrics that are being collected from the server.
- You’ve set realistic SLO objectives for the two cases that are achievable in the short term.
- [Optional] You set aspirational SLOs based on what your users would expect in the long term.

### Learning Resources

### How do metrics differ from SLIs?

Metrics and Service Level Indicators (SLIs) both provide valuable data about a system’s performance, but they serve distinct roles. Metrics are broad measurements that capture various aspects of system activity, such as CPU usage, latency, and error rates. They form the foundational data used to observe, monitor, and troubleshoot a system. SLIs, on the other hand, are carefully selected metrics that directly reflect the quality of service experienced by users. Focusing on factors like availability, latency, or error rate, SLIs gauge how well a service is meeting specific reliability targets known as Service Level Objectives (SLOs). While metrics provide a comprehensive view of system health, SLIs narrow the focus to measure the specific qualities that most affect user satisfaction, aligning system performance with business objectives.

### Latency Metrics

- These metrics (for all dashboards) measures how long it takes for users to get a successful response from the server.
- It provides insights into the speed and efficiency of a specific server process (eg: login, chat, etc).
- Lower latency means faster logins, contributing to a better user experience.
- The dashboard displays several percentiles of login latency (10th, 50th, 90th, 95th, 99th), giving you a comprehensive view of the login speed distribution.
- This metric is also displayed as a line chart, allowing you to track changes in latency over time and identify any performance degradations.

## Challenge 5: SLOs on the dashboard

### Prerequisites

Run the following command on a terminal (**Cloud Shell terminal**).

> **Note**: With this command we're priming the backend that generates metrics to behave in a specific way.

```sh
## Check if the BACKEND_ADDRESS env variable is set in your environment before you do this.

curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
  "ChatSuccess": 0.95,
  "ChatSafetyIssue": 0.1,
  "ChatEngaged": 0.70,
  "ChatAcknowledged": 0.15,
  "ChatRejected": 0.05,
  "ChatUnclassified": 0.1,
  "ChatSPositive": 0.6,
  "ChatSNegative": 0.1,
  "ChatSNeutral": 0.2,
  "ChatSUnclassified": 0.1,
  "LoginSuccess": 0.999,
  "StartupSuccess": 0.95,
  "PrefUpdateSuccess": 0.99,
  "PrefGetSuccess": 0.999,
  "LoginLatencyMinMS": 10,
  "LoginLatencyMaxMS": 200,
  "ChatLatencyMinMS": 906,
  "ChatLatencyMaxMS": 4683,
  "StartupLatencyMinMS": 400,
  "StartupLatencyMaxMS": 1000,
  "PrefGetLatencyMinMS": 153,
  "PrefGetLatencyMaxMS": 348,
  "PrefUpdateLatencyMinMS": 363,
  "PrefUpdateLatencyMaxMS": 645
}' \
$BACKEND_ADDRESS/phase 
```

### Introduction

This challenge is about up the short-term Service Level Objectives (SLOs) for the app in Cloud Monitoring Suite. SLOs help you define and track the performance targets for your service, ensuring a positive user experience.

#### Steps

1. **Create a service in the UI**
    In the context of GCP SLOs and services, *creating* a service doesn't mean building the service itself from scratch. It means defining the service as a monitored entity within Cloud Monitoring.

   - Go to the **SLOs** tab in the monitoring suite. This is where you'll define and manage your SLOs.
   - Click create **new service**.
   - Under **service candidates**, select **mockserver-service** This links your SLOs to the correct service for monitoring.
   - Give it a **Display name**. It can be anything. Use **mockserver-service** if you can't think of anything else.

    > **Note**: You can also create these via the API. Check **Tips** in **Learning Resources** for creating services via the API.

    ![SLO UI](images/SLO_Success.png)

1. **Create 4 SLOs**
  
   Now, let's create the specific SLOs for your service:

   - Chat Latency:
     - Metric: **movieguru_chat_latency_milliseconds_bucket** (look under the **prometheus targets > movieguru** section)
     - Target: p99 latency of **5 seconds** (5000 milliseconds)
     - Time Window: **24-hour** rolling window

   - Chat Engagement:
     - Metric: **movieguru_chat_outcome_counter_total** (Filter: Outcome=Engaged)
     - Target: 70% of chat interactions should result in an "Engaged" outcome.
     - Time Window: **24-hour** rolling window
     - Remarks: Ideally we would like to use **Outcome=Engaged** and **Outcome=Accepted** to indicate that the user finds the response relevant, but we will stick to just Engaged for now. [Optional] If you want to use a filter that incorporates both **Engaged** and **Acknowledged**, use the monitoring API to create the SLO.

   - Main Page Load Latency:
     - Metric: **movieguru_startup_latency_milliseconds_bucket** (measured at the **startup** endpoint)
     - Target: p99 latency of **1 second** (1000 milliseconds)
     - Time Window: Choose an appropriate time window, such as a 24-hour or 7-day rolling window.

   - Main Page Load Success Rate:
     - Metric: This requires combining two metrics: **movieguru_startup_success_total** and **movieguru_startup_attempts_total**.
     - Target: 90% success rate over a 7-day rolling window.
     - Remarks: Since the UI doesn't support combining metrics, you'll need to use the Cloud Monitoring API to define this SLO. This allows for more complex SLO configurations (see **Learning Resources**).

> **Note**: You can also create these via the API. Check **Tips** in **Learning Resources** for creating  SLOs via the API.

### Success Criteria

- You have all the SLOs created.
- You have created atleast 1 SLO through the Monitoring API.

### Learning Resources

- [Setting SLOs through UI](https://cloud.google.com/stackdriver/docs/solutions/slo-monitoring/ui/create-slo)
- [Setting SLOs with API](https://cloud.google.com/stackdriver/docs/solutions/slo-monitoring/api/using-api#slo-create)

### Tips

See below for high level steps for creating services and SLOs via API

Use the [Setting SLOs with API](https://cloud.google.com/stackdriver/docs/solutions/slo-monitoring/api/using-api#slo-create) as a reference for finding the right commands for the following steps.

1. Create an access token.
1. Create a service with a name like **movieguru-backend** (you can use a pre-existing service, but their id's need to be referenced. For this step, it's just easier to create one.)
1. Create an SLO definition.
1. Create the SLO from the definition.

#### Example

```sh
## Make sure the env variable PROJECT_ID is set.

## Get an access token
ACCESS_TOKEN=`gcloud auth print-access-token`

## Create a custom service definition
SERVICE_ID=movieguru-service
CREATE_SERVICE_POST_BODY=$(cat <<EOF
{
  "displayName": "${SERVICE_ID}",
  "gkeService": {
    "projectId": "${PROJECT_ID}",
    "location": "europe-west4",
    "clusterName": "movie-guru-gke",
    "namespaceName": "movie-guru",
    "serviceName": "mockserver-service"
  }
}
EOF
)

## POST to create the service
curl  --http1.1 --header "Authorization: Bearer ${ACCESS_TOKEN}" --header "Content-Type: application/json" -X POST -d "${CREATE_SERVICE_POST_BODY}" https://monitoring.googleapis.com/v3/projects/${PROJECT_ID}/services?service_id=${SERVICE_ID}

## Create an SLO definition
CHAT_ENGAGEMENT_SLO_POST_BODY=$(cat <<EOF
{
  "displayName": "70% - Chat Engagement Rate - Calendar day",
  "goal": 0.7,
  "calendarPeriod": "DAY",
  "serviceLevelIndicator": {
    "requestBased": {
      "goodTotalRatio": {
        "goodServiceFilter": "metric.type=\"prometheus.googleapis.com/movieguru_chat_outcome_counter_total/counter\" resource.type=\"prometheus_target\" metric.labels.Outcome=monitoring.regex.full_match(\"Engaged|Acknowledged\")",
        "totalServiceFilter": "metric.type=\"prometheus.googleapis.com/movieguru_chat_outcome_counter_total/counter\" resource.type=\"prometheus_target\""
      }
    }
  }
}
EOF
)

## POST the SLO definition
curl  --http1.1 --header "Authorization: Bearer ${ACCESS_TOKEN}" --header "Content-Type: application/json" -X POST -d "${CHAT_ENGAGEMENT_SLO_POST_BODY}" https://monitoring.googleapis.com/v3/projects/${PROJECT_ID}/services/${SERVICE_ID}/serviceLevelObjectives

```

## Challenge 6: Stay alert

### Prerequisites

Run this command in the terminal (**Cloud Shell terminal**).

> **Note**: With this command we're priming the backend that generates metrics to behave in a specific way.

```sh
## Check if the BACKEND_ADDRESS env variable is set in your environment before you do this.

curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
  "ChatSuccess": 0.95,
  "ChatSafetyIssue": 0.1,
  "ChatEngaged": 0.40,
  "ChatAcknowledged": 0.10,
  "ChatRejected": 0.05,
  "ChatUnclassified": 0.2,
  "ChatSPositive": 0.6,
  "ChatSNegative": 0.1,
  "ChatSNeutral": 0.2,
  "ChatSUnclassified": 0.1,
  "LoginSuccess": 0.999,
  "StartupSuccess": 0.95,
  "PrefUpdateSuccess": 0.99,
  "PrefGetSuccess": 0.999,
  "LoginLatencyMinMS": 10,
  "LoginLatencyMaxMS": 200,
  "ChatLatencyMinMS": 4500,
  "ChatLatencyMaxMS": 8000,
  "StartupLatencyMinMS": 400,
  "StartupLatencyMaxMS": 1000,
  "PrefGetLatencyMinMS": 153,
  "PrefGetLatencyMaxMS": 348,
  "PrefUpdateLatencyMinMS": 363,
  "PrefUpdateLatencyMaxMS": 645
}' \
$BACKEND_ADDRESS/phase
```

### Introduction

This challenge guides you through monitoring the four SLOs created in the previous challenge.

- **Perform an Initial Observation**: Initially, all Service Level Indicators (SLIs) should be within the acceptable range of the objective. Minor, short-term dips below the objective are normal and not a cause for concern, as long as the SLO is met within the specified time window. (Verify this on your SLO dashboard)

- **Error Budget and Maintenance**: Examine the error budget for the Startup Success Rate SLO. The error budget represents the allowed deviation from the SLO. (Check out Learning Resources if you need a refresher on **Error budgets** or **Burn Rates**)

- This is how a healthy SLO would look like (it isn’t required to be always above the line)

   ![Short dips in SLI are OK](images/short_dips_are_ok.png)

### Description

- Click on the **Error Budget** view for each SLO to view the error budget and burn rate.
  - The burn rate is the rate at which this error budget line is changing.
  - If there were no issues, or planned maintainence events and everything operated perfectly, the error budget would remain at 100%.
  - A healthy burn rate is beneficial, indicating that you are utilizing your error budgets effectively for improvements and planned maintenance. If you error budget is near 100% at the end of the compliance period, then you're likely wasting these windows.
  - While you established the SLOs in Challenge 5, it's important to note that the error budgets are calculated from the beginning of the lab, as metrics collection commenced in Challenge 1.
- **Create Burn Rate Alerts**
  Let’s be honest—you can’t just sit there staring at dashboards all day without turning into a zombie! So, give your setup a little pizzazz by creating alerts to let you know when things start to go awry. Make sure to have one for those *bad* moments and another for *really really bad* moments.
  - Create **SLO alerts** from the UI for all the SLOs
  - To differentiate between the severity of issues, set two alerts for each SLO (use a 15 minute lookback window):
    - **Slow burn rate alert** (1.5-2.0x): Indicates minor issues or gradual degradation.
    - **Fast burn rate alert** (10x): Signals major outages requiring immediate attention.
- Run this command in the terminal (**Cloud Shell terminal**). This simulates your app team making some changes to the app.

  ```sh
  ## Check if the BACKEND_ADDRESS env variable is set in your environment before you do this.

  curl -X POST \
    -H "Content-Type: application/json" \
    -d '{
    "ChatSuccess": 0.95,
    "ChatSafetyIssue": 0.1,
    "ChatEngaged": 0.40,
    "ChatAcknowledged": 0.10,
    "ChatRejected": 0.45,
    "ChatUnclassified": 0.05,
    "ChatSPositive": 0.6,
    "ChatSNegative": 0.1,
    "ChatSNeutral": 0.2,
    "ChatSUnclassified": 0.1,
    "LoginSuccess": 0.999,
    "StartupSuccess": 0.95,
    "PrefUpdateSuccess": 0.99,
    "PrefGetSuccess": 0.999,
    "LoginLatencyMinMS": 10,
    "LoginLatencyMaxMS": 200,
    "ChatLatencyMinMS": 4500,
    "ChatLatencyMaxMS": 8000,
    "StartupLatencyMinMS": 400,
    "StartupLatencyMaxMS": 1000,
    "PrefGetLatencyMinMS": 153,
    "PrefGetLatencyMaxMS": 348,
    "PrefUpdateLatencyMinMS": 363,
    "PrefUpdateLatencyMaxMS": 645
  }' \
  $BACKEND_ADDRESS/phase
  ```

- **Observing Alert Triggers**:  
  - Wait for about 5-10 minutes.
  - Which SLOs are triggering alerts? This indicates which services are failing to meet their objectives.
  - What is the burn rate of the triggered alerts? This shows how quickly the SLO is degrading. A faster burn rate (e.g., 10x) signals a more urgent issue.

> **Warning**: Having trouble triggering alerts? Don't worry, it might just be due to the lab setting! Keep in mind that the SLIs very performing very badly at the start of the lab, eating into the error budgets even after an "improvement" was simulated. The alerts might not fire if you are already out of budget. Just look at the error budgets burn rates and figure out which SLOs require immediate attention, and which ones are being slightly problematic.

```text
Simplified formula to estimate Burn Rate = 
((Error Budget at Start of look back window − Current Error Budget)/Window Length) x 100 %

```

### Success Criteria

To verify successful completion of this exercise, check the following:

- **Burn Rate Triggers**: Ensure you have created 2 burn rate alerts for all your SLOs (8 in total).
  - These alerts should be configured to trigger at different burn rates (e.g., 1.5-2.0x for slow burn, 10x for fast burn) to capture varying levels of degradation.
- **Alert Activity**: While the exact number of alerts triggered will vary depending on the system's behavior, you should expect 3 alerts. Both burn rate alerts should fire for the "Chat Latency" SLO, and the slow burn rate alert should fire for the "Chat Engagement SLO".

### Learning Resources

#### What are **error budgets**

An error budget is the acceptable amount of time your service can fail to meet its SLOs, helping you balance innovation and reliability. Calculated as 1 - SLO, a 99% availability SLO gives you a 1% error budget (about 7.3 hours per month) for new features, maintenance, and experimentation.  Error budgets promote proactive risk management and informed decision-making about service reliability.

#### What is a **burn rate**

Informal Formula: (Error budget at start of window - Error budge now)/window length x 100

Burn rate measures how quickly you're using up your error budget.  It acts as an early warning system for SLO violations, helping you prioritize and respond to issues before they impact users. Calculated as a multiple of your error budget consumption, a high burn rate (e.g., 10x) signals a major problem needing immediate action. A slow burn rate (generally configured over a longer interval) alerts you if you are likely to exhaust your error budget before the end of the compliance period. It is less urgent than a fast burn, but signals something may be wrong, but not urgent. Setting alerts for different burn rates (e.g., 2x for slow burn, 10x for fast burn) allows you to proactively manage service reliability and keep users happy. By monitoring burn rate, you can ensure your services meet their SLOs and avoid "overspending" your error budget.

- [SLO alerting on Burn Rate](https://cloud.google.com/stackdriver/docs/solutions/slo-monitoring/alerting-on-budget-burn-rate)
- [Creating alerting policies with the UI](https://cloud.google.com/stackdriver/docs/solutions/slo-monitoring/ui/create-alert)

## Challenge 7: What's really UP, doc?

### Prerequisites

- Connect to the GKE cluster from the **Cloud Shell terminal** by running the following command.

```sh
$GKE_CONNECTION_STRING
```

- Deploy a new frontend version

```sh
kubectl apply -f <(curl -s https://raw.githubusercontent.com/MKand/movie-guru/refs/heads/ghack-sre/k8s/frontend-v2.yaml)
```

- Reset the backend server

> **Note**: With this command we're priming the backend that generates metrics to behave in a specific way. This simulates your colleagues making some changes that might have broken a few things.

```sh
## Check if the BACKEND_ADDRESS env variable is set in your environment before you do this.

curl -X POST \
  -H "Content-Type: application/json" \
  -d '{
  "ChatSuccess": 0.95,
  "ChatSafetyIssue": 0.1,
  "ChatEngaged": 0.70,
  "ChatAcknowledged": 0.15,
  "ChatRejected": 0.05,
  "ChatUnclassified": 0.1,
  "ChatSPositive": 0.6,
  "ChatSNegative": 0.1,
  "ChatSNeutral": 0.2,
  "ChatSUnclassified": 0.1,
  "LoginSuccess": 0.999,
  "StartupSuccess": 0.95,
  "PrefUpdateSuccess": 0.99,
  "PrefGetSuccess": 0.999,
  "LoginLatencyMinMS": 10,
  "LoginLatencyMaxMS": 200,
  "ChatLatencyMinMS": 906,
  "ChatLatencyMaxMS": 4683,
  "StartupLatencyMinMS": 400,
  "StartupLatencyMaxMS": 1000,
  "PrefGetLatencyMinMS": 153,
  "PrefGetLatencyMaxMS": 348,
  "PrefUpdateLatencyMinMS": 363,
  "PrefUpdateLatencyMaxMS": 645
}' \
$BACKEND_ADDRESS/phase 
```

### Introduction

**The Calm Before the Storm**

You settle in for another day of SRE serenity, casually monitoring the dashboards and basking in the glow of Movie Guru's stable performance.  Suddenly, your peaceful morning is shattered by a frantic colleague from customer support.

**"Mayday! Mayday!"** they exclaim, bursting into your cubicle. "*Users are reporting that Movie Guru is acting up! They can't seem to use the website properly!*"

### Description

- **Look at your dashboards**

  - Check the SLO dashboards, if the backend server has been reset correctly (prerequisite step), and a few minutes have passed, you should see that the **Startup SLOs** are well within expected range.

- **Investigate the Issue**

  - To get to the bottom of this mystery, open a new **incognito/private** browser window and navigate to the Movie Guru frontend.
  - Refresh the page a few times and see if you spot something wrong.

- **Your Challenge:**

  - **Observe:**  Carefully observe what happens when you try to use the Movie Guru website. What issues are you experiencing?
  - **Analyze:**  Compare your observations with the data displayed on the dashboards. What discrepancies do you notice?
  - **Explain:**  Explain the reason for the difference between what users are reporting and what the dashboards are showing. What might be causing this discrepancy?
  - **Consider:**  What are the implications of this discrepancy for your monitoring and alerting strategy? How can you improve your monitoring to better reflect the actual user experience?

### Success Criteria

To successfully complete this challenge, you should be able to:

- **Identify the monitoring gap:**  Explain that the current dashboards only track server-side metrics and lack visibility into the frontend performance, leading to a blind spot in monitoring.
- **Pinpoint the potential cause:**  Deduce that a recent change likely broke the connection between the frontend and backend, causing the user-facing issues.
- **(Optional) Dive deeper:** Investigate further and discover the root cause: half of the frontend pods are configured with an incorrect backend URL, preventing them from communicating with the backend.
- **Realize the importance of end-to-end monitoring:** Understand that monitoring user-facing interfaces and interactions is crucial for accurately reflecting the user experience and detecting issues that may not be visible in server-side metrics alone.
- **Propose solutions:** Suggest ways to improve monitoring, such as real user monitoring (RUM) to track frontend performance and availability from the user's perspective.

### Learning Resources

- [SRE Books](https://sre.google)
- [SRE workbook](https://sre.google/workbook/table-of-contents/)