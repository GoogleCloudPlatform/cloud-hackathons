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