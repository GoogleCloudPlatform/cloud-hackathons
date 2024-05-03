# gHacking with Gemini CodeAssist

## Introduction

Welcome to the coach's guide for gHacking with Gemini CodeAssist. gHack. Here you will find links to specific guidance for coaches for each of the challenges.

Remember that this hack includes a optional [lecture presentation](resources/lecture.pdf) that features short presentations to introduce key topics associated with each challenge. It is recommended that the host present each short presentation before attendees kick off that challenge.

> **Note** If you are a gHacks participant, this is the answer guide. Don't cheat yourself by looking at this guide during the hack!

## Coach's Guides

- Challenge 1: Clone the Quotes app
   - Get started with your GCP project and clone the repository to edit within your environment.
- Challenge 2: Get started with Gemini CodeAssist
   - Experiment with prompt engineering to understand the Gemini CodeAssist feature.
- Challenge 3: Test-Driven Development
   - Have Gemini help you to add business logic using test-driven development guidelines.
- Challenge 4: Build, deploy, and test
   - Build and deploy the updated Quotes app to Cloud Run and test the endpoint.
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

## Challenge 1: Provision an IoT environment

### Notes & Guidance

This is the only section you need to include.

Use general non-bulleted text for the beginning of a solution area for this challenge
- Then move into bullets
    - And sub-bullets and even
        - sub-sub-bullets
# Task 1. Setup the prerequisites

**Activate Cloud Shell**
- Cloud Shell is a virtual machine that is loaded with development tools. It offers a persistent 5GB home directory and runs on the Google Cloud. Cloud Shell provides command-line access to your Google Cloud resources.
- In the Cloud Console, in the top right toolbar, click the Activate Cloud Shell button.

- Click Continue.


It takes a few moments to provision and connect to the environment. When you are connected, you are already authenticated, and the project is set to your PROJECT_ID. For example:

Enable Gemini
Start by obtaining new credentials, by typing the following command, authorizing the request at the shared link, then copy/paste the authorization code in the Terminal :

gcloud auth login


Enable the APIs required by the Quotes application:
#enable the DuetAI
gcloud services enable cloudaicompanion.googleapis.com


To use Duet AI in the Console, click on the button in the navigation bar to open the Duet AI chat panel:

Click "Start Chatting" and try a few queries about GCP or general programming related topics. For example:
When programming should I use tabs or spaces?


Open the Editor
As you are opening it in an incognito window, the editor will ask you to Open In a new window

Enabling Duet AI in the Cloud Shell Editor
Duet AI is available in a range of Editors. For the full list check the official documentation.
In this lab we will use the Cloud Shell Editor but the instructions for enabling Duet AI are the same for all VS-Code based editors.
Once the editor has loaded, make sure you have the Cloud Code Extension installed. For Cloud Shell Editor this extension is automatically installed for you. If you were to use your own IDE you might have to install it manually.
Open the settings page via Menu > File > Preferences > Settings by using the shortcut of CTRL+, (CMD+, for macOS).
In the settings page search for "Duet AI" and check the boxes for using Duet AI and to enable suggestions. 
Lastly, you'll need to set the GCP project that Duet AI will be using. We'll use the project that you were given in the Qwiklabs instructions page. Don't worry about saving the changes. They are automatically saved on edit.

At the bottom left of the editor you'll see a button with the label "Cloud Code - Sign in". Click to login to the lab's GCP account. After a few seconds of clicking the button you should see the label change to "Cloud Code - No Project".

The Duet AI chat window on the right side of the editor will now be available for you to ask generic and context specific questions.

Let's move to the next step to see the Duet AI chat in action.
From the top menu, open a Terminal window, for command-line operations:

Inside your Terminal window, set the following environment variables for the scripts in this lab, as well as install the latest version of Java:
Note: to copy code snippets, you can hover over mouse to upper right corner of code block where the copy button will show up 

Set the project ID:
gcloud config set project <your project id from the lab start screen>


Validate that the project is set with the command:

gcloud config list


Install the latest Java version - Java 21 with the SDKMan Software Developer Kit Manager, for the simplest installation:
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh" 


Install the latest OpenJDK and confirm it as the default JDK in the install

#install OpenJDK
sdk install java 21.0.2-tem && sdk use java 21.0.2-tem && java -version


Enable the APIs required by the Quotes application, if they are not already activated:
#enable the DuetAI, Cloud Run, Cloud Build and Logging APIs
gcloud services enable cloudaicompanion.googleapis.com
gcloud services enable cloudbuild.googleapis.com 
gcloud services enable run.googleapis.com
gcloud services enable logging.googleapis.com 


Task 2. Download and validate the Quotes app codebase
Run the following steps in Cloud Shell window activated in Task 1 to create and build the application:

First, let’s get the codebase for Quotes by cloning the Github repo and switching to the /services/quotes folder:
# clone the repo
git clone https://github.com/GoogleCloudPlatform/serverless-production-readiness-java-gcp.git
cd serverless-production-readiness-java-gcp/services/quotes


Open the codebase in the IDE, by adding the serverless-production-readiness-java-gcp/services/quotes folder to the Workspace:



VSCode suggests  to add a Java Extension pack; enable it,  as it is the only recommendation which you would find useful in this lab; you can ignore the others:


Observe that the Java Project is being opened, this takes a few seconds:


Explore the codebase by clicking on the Explorer, the top-left icon, or navigating to:


After opening the code in the Explorer, you might observe that the DuetAI button is disabled.
Repeat the previous sign in step:  at the bottom left of the editor you'll see a button with the label "Cloud Code - Sign in". Click to login to the lab's GCP account. After a few seconds of clicking the button you should see the label change to "Cloud Code - No Project" and Duet AI is enabled.


If the terminal window is closed, re-open it and set the project as in the previous step:

#set the project
gcloud config set project <your project ID>


Then set the PROJECT_ID environment variable:

#set the PROJECT_ID env variable
export PROJECT_ID=$(gcloud config list --format 'value(core.project)')
echo   $PROJECT_ID


Check that the project is set:
#validate it with the command
gcloud config list

Validate that you have Java 21 and Maven installed:
sdk use java 21.0.2-tem && java -version

Validate that the starter app is good to go:
./mvnw package spring-boot:run

Open a new terminal window. From the terminal window, test the app:
curl localhost:8083/start -w "\n"


# Output
QuoteController started!
In the terminal window where the app is running, Stop the running app using CTRL+C
Alternatively, you can start the Quotes app also by using plain Java:
java -jar target/quotes-1.0.0.jar 

Build a JIT Docker image with Dockerfiles:
# build an image with a fat JAR
docker build -f ./containerize/Dockerfile-fatjar -t quotes .

# build an image with custom layers
docker build -f ./containerize/Dockerfile-custom -t quotes-custom .

Build a Java Docker image with Buildpacks:
./mvnw spring-boot:build-image -DskipTests -Dspring-boot.build-image.imageName=quotes

Test the locally built images on the local machine from a terminal window:
docker run --rm -p 8080:8083 quotes


#Test the start endpoint
curl localhost:8080/start -w "\n"

Stop the running Docker container with CTRL+C

Break things apart with more than one bullet list
- Like this 
- One
- Right
- Here
