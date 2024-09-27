# AI App hack

## Introduction

This is a coaches guide for this ghack.
This hack helps you create and deploy a GenAI application (see below) using Google Cloud and Firebase Genkit.
You do the following:
- Part1: Add data into the vector database.
- Part1: Creating GenAI flows that power this app.
- Part1: Building security and validation into model responses.
- Part1: Run this application locally.
- Part2: Make this a fully cloud based application (Deploy the application on GCP) using firebase, cloudrun, memory store for redis.

> **Note** If you are a gHacks participant, this is the answer guide. Don't cheat yourself by looking at this guide during the hack!

## Coach's Guides


- Challenge 1: Upload the data to the vector database
   - Create an embedding for each entry in the dataset (discussed later), and upload the data to a vector database using the predefined schema. Do this using a genkit flow.
- Challenge 2: Your first flow that analyses the user's input.
   - Create a flow that takes the user's latest input and make sure you extract *any* long term preference or dislike. 
- Challenge 3: Flow that analyses the converstation history and transforms the user's latest query with the relevant context.
- Challenge 4: Retrieve the relevant documents from the transformed context created at the previous challenge.
- Challenge 5: Create a meaningful response to the user (RAG flow).
   - Select the relevant outputs from the previous stages and return a meaningful output to the user.

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

## Suggested Hack Agenda (Optional)

_This section is optional. You may wish to provide an estimate of how long each challenge should take for an average squad of students to complete and/or a proposal of how many challenges a coach should structure each session for a multi-session hack event. For example:_

- Sample Day 1
  - Challenge 1 (45 mins)
  - Challenge 2 (15 mins)
  - Challenge 3 (15 mins)
  - Challenge 4 (30 mins)
  - Challenge 5 (30 mins)


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

## Challenge 1: Upload the data to the vector database

### Notes & Guidance

[Solution for Challenge 1: GoLang](https://github.com/MKand/movie-guru/blob/main/chat_server_go/pkg/flows/indexerFlow.go)
[Solution for Challenge 1: JS]()
- Students create a **content** entry with the following fields (Title, Plot, Director, Runtime_mins, Rating, Release, Director, Actors). *Poster* and *tconst* are excluded. 
- They write createText method to include all the aforementioned fields and format the **Genre** and **Actors** fields, as you want comma seperated values. 
- They create an embedding for the output of the **createText** method.
- They upload the entry (embedding and other fields) into the **movies** table
