# Practical SRE

## Introduction

Welcome to the coach's guide for The IoT Hack of the Century gHack. Here you will find links to specific guidance for coaches for each of the challenges.

Remember that this hack includes a optional [lecture presentation](resources/lecture.pdf) that features short presentations to introduce key topics associated with each challenge. It is recommended that the host present each short presentation before attendees kick off that challenge.

> **Note** If you are a gHacks participant, this is the answer guide. Don't cheat yourself by looking at this guide during the hack!

## Coach's Guides

- Challenge 1: Your first day as SRE
  - Create an IoT Hub and run tests to ensure it can ingest telemetry

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

- Cloud Observability Suite
- 

## Suggested Hack Agenda (Optional)

_This section is optional. You may wish to provide an estimate of how long each challenge should take for an average squad of students to complete and/or a proposal of how many challenges a coach should structure each session for a multi-session hack event. For example:_

- Sample Day 1
  - Challenge 1 (1 hour)
  - Challenge 2 (30 mins)
  - Challenge 3 (2 hours)
- Sample Day 2
  - Challenge 4 (45 mins)
  - Challenge 5 (1 hour)
  - Challenge 6 (45 mins)

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
  - Make sure the students take a note of the **Locust IP** and the **Frontend IP**

## Challenge 1: Your first day as SRE

### Notes & Guidance

#### Getting Started

1. **Start Metrics Collection:** Begin by launching the load tester tool to collect background metrics. This data will be used in later challenges.
2. **Explore the App:**  Each student should access the Movie Guru app on their own machine using the provided frontend IP address. Take 10 minutes to explore the app individually.

#### Identifying User Journeys

1. **Teamwork:**  The team has to work together to identify at least 2 user journeys.  Think about the different ways users might interact with the app to achieve specific goals.
1. **Compare and Contrast:** They need to identified user journeys with the examples provided in the "Success Criteria" section.  Remember that these examples are not the definitive "right answers."  Your team might identify important details or variations that are not captured in the examples.
1. **Structured Documentation:**  Clearly document your user journeys using a structured format that includes:
   1. **Goal:** The user's objective in this journey.
   1. **Steps:** The specific actions the user takes to achieve the goal.

#### Important Reminders

- The goal of this challenge is to familiarize themselves with the Movie Guru app and practice identifying user journeys.
- There is no single "correct" set of user journeys.  Focus on capturing the key interactions and user goals.
- Documenting user journeys in a structured format helps ensure clarity and facilitates future analysis and improvements.

## Challenge 2: There are others

This challenge focuses on stakeholder management, SRE principles, and gathering information. Here's a guide to help you facilitate the exercise:

**Key takeaways for students:**

- **100% uptime is an unrealistic goal:**  Emphasize the trade-offs between reliability, cost, and innovation.
- **SRE is about balance:**  Help students understand the importance of balancing reliability with user needs and business priorities.
- **Collaboration is key:**  Stress the importance of identifying and collaborating with key stakeholders across different teams.
- **Information gathering is crucial:** Guide students to identify the essential information needed to assess and improve reliability.

**Guiding the discussion:**

- **Challenge the CEO's demand:** Encourage students to critically evaluate the CEO's demand and explain why 100% uptime is not a feasible or desirable goal.
- **Explore SRE principles:**  Use this opportunity to discuss core SRE principles like SLOs, error budgets, and embracing risk.
- **Identify stakeholders:**  Guide students to identify a wide range of stakeholders, including technical teams, product owners, and business stakeholders.
- **Gather essential information:**  Help students determine the specific information needed from each stakeholder group to develop a comprehensive reliability strategy.
- **Facilitate role-play:**  Encourage students to role-play the conversation with the CEO, focusing on clear communication and alignment with SRE principles.

**Remember:** The goal is not to find the "perfect" solution but to encourage critical thinking, collaboration, and a deeper understanding of SRE principles and make them tangible.

## Challenge 3: Your first set of SLOs

## Instructor's Guide: Challenge 3

This challenge focuses on defining and understanding Service Level Objectives (SLOs). Here's a guide to help you facilitate the exercise:

**Key takeaways for students:**

- **SLOs are key to SRE:**  Emphasize the importance of SLOs in defining and measuring service reliability.
- **Align with user needs:**  Help students understand that SLOs should be based on what matters most to users, not arbitrary targets.
- **SMART SLOs:** Guide students to create SLOs that are specific, measurable, achievable, relevant, and time-bound.
- **Components of an SLO:** Ensure students understand the key components of an SLO: objective, SLI, target, time window, and measurement.

**Guiding the discussion:**

- **Review SLO concepts:**  Start by reviewing the definition and purpose of SLOs, using the provided "What are SLOs?" section as a reference.
- **Choose user journeys:**  Help students select relevant user journeys from Challenge 1 or the provided examples.
- **Define SLOs:** Guide students to define appropriate SLOs for each chosen user journey, ensuring they include all the necessary components.
- **Discuss measurement:** Encourage students to think about how they would measure and track the defined SLOs.
- **Provide feedback:** Offer constructive feedback on the students' SLOs, focusing on clarity, relevance, and measurability.

**Example SLO discussion points:**

- **Why is this SLO relevant to the chosen user journey?**
- **How would you measure the SLI?**
- **What tools or data sources would you use?**
- **How would you know if the SLO is being met?**
- **What actions might you take if the SLO is not met?**

**Remember:** The goal is to help students develop a strong understanding of SLOs and their role in SRE. Encourage them to think critically about user needs, business goals, and the technical aspects of measuring and achieving reliability targets.

### Example **Movie Guru** SLOs

#### SLO for Movie Guru App Access

- SLO: 99.95% of users should be able to access the Movie Guru app and view the main interface within 3 seconds, measured over a 7-day rolling window.

- Rationale:

    This SLO focuses on the app's availability and initial load time, which are crucial for a positive first impression.  The 99.95% target ensures high availability, while the 3-second threshold aims for a responsive and quick-loading interface. The 7-day rolling window provides a balance between capturing short-term trends and allowing for some variability in daily traffic patterns.

- Measurement:

  - Availability: Measured as the percentage of successful attempts to access and load the main interface of the Movie Guru app.
  - Latency: Calculated as the combined latency of the login endpoint and the startup endpoint, both measured at the server

#### SLO for Movie Guru Chatbot Responsiveness

**Current SLO:** 70% of user messages should receive a relevant response from the Movie Guru chatbot within 8 seconds, measured over a 24-hour rolling window.

**Aspirational SLO:** 90% of user messages should receive a relevant response from the Movie Guru chatbot within 5 seconds, measured over a 24-hour rolling window.

**Rationale:**

This starting SLO acknowledges that the chatbot is still under development and may not yet be able to provide highly relevant responses in all cases. The 70% target allows for some room for improvement while still ensuring a reasonable level of user satisfaction. The aspirational SLO sets a higher bar for the future, aiming for both improved relevance and reduced latency.

**Measurement:**

- **Relevance:** Measured by the `Chat_Outcome_Counter` metric. A response is considered relevant if the outcome is registered as "engaged"."
- **Latency:**  Calculated as the time difference between the server receiving the user's message and sending the response.

#### SLO for Updating User Preferences in Movie Guru

- SLO: 99.5% of user preference updates should be successfully saved within 1 second, measured over a 24-hour rolling window.

- Rationale:

    This SLO focuses on the performance and reliability of the preference update functionality within Movie Guru. The 99.5% target ensures that users can reliably modify their preferences, while the 1-second threshold aims for a quick and responsive experience. The 24-hour rolling window provides a frequent assessment of this critical function.

- Measurement:

  - Success Rate: Measured as the percentage of successful attempts to update user preferences.
  - Latency: Calculated as the time it takes for the app to successfully save the updated preferences after a user submits the changes.

## Challenge 4: Let the monitoring begin

This section helps you address the challenges in defining and achieving SLOs for the Movie Guru app.

SLO 1: App Accessibility and Responsiveness

Current State: 90% availability, p99 latency of 3 seconds.
Target SLO: 99% of users access the main interface within 1 seconds over a 7-day rolling window.

SLO 2: Chatbot Responsiveness

Current State: 50% engagement rate, p99 latency of 9.8 seconds.
Target SLO: 70% of user messages receive a relevant response within 5 seconds over a 24-hour rolling window.


## Challenge 5: Implementing SLOs on the dashboard

This is a challenging exercise. The last SLO needs to be implmenting using the API as the GCP Monitoring UI for SLIs doesn't allow you to define different metrics in the numerator and denominator.
Here is the command for it that needs to be run in a terminal.

```sh
ACCESS_TOKEN=`gcloud auth print-access-token`


CREATE_SERVICE_POST_BODY=$(cat <<EOF
{
  "displayName": "mockserver-service",
  "gkeService": {
    "projectId": "movie-guru-ghack",
    "location": "europe-west4",
    "clusterName": "movie-guru-gke",
    "namespaceName": "movie-guru",
    "serviceName": "mockserver-service"
  }
}
EOF
)

SERVICE_ID=service-startup

curl  --http1.1 --header "Authorization: Bearer ${ACCESS_TOKEN}" --header "Content-Type: application/json" -X POST -d "${CREATE_SERVICE_POST_BODY}" https://monitoring.googleapis.com/v3/projects/${PROJECT_ID}/services?service_id=${SERVICE_ID}


CREATE_SLO_POST_BODY=$(cat <<EOF
{
  "displayName": "90% - Startup Success - Calendar Week",
  "goal": 0.90,
  "calendarPeriod": "WEEK",
  "serviceLevelIndicator": {
    "requestBased": {
      "goodTotalRatio": {
        "goodServiceFilter": "metric.type=\"prometheus.googleapis.com/movieguru_startup_success_total/counter\" resource.type=\"prometheus_target\"",
        "totalServiceFilter": "metric.type=\"prometheus.googleapis.com/movieguru_startup_attempts_total/counter\" resource.type=\"prometheus_target\""
      }
    }
  }
}
EOF
)
curl  --http1.1 --header "Authorization: Bearer ${ACCESS_TOKEN}" --header "Content-Type: application/json" -X POST -d "${CREATE_SLO_POST_BODY}" https://monitoring.googleapis.com/v3/projects/${PROJECT_ID}/services/${SERVICE_ID}/serviceLevelObjectives

```