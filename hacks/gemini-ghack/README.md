# gHacking with Gemini CodeAssist

## Introduction

Your team is asking you to enhance the existing Book Quotes application by adding new business functionality to retrieve quotes from books, given the book name. As you don’t have any prior experience with the Quotes service, you enlist the help of your trusted developer assistant, Gemini Code Assist, to understand the service, add the required functionality and write proper tests.

You choose to follow a test-driven development process, relying on requirements being converted to test cases before the service is fully developed. You track the development by repeatedly testing the service against all test cases, first in your local environment, then in a Serverless environment in GCP. 

## Learning Objectives

In this gHack you will learn how to add business functionality to an existing Java and Spring Boot serverless application using the Gemini CodeAssist feature. 

1. Set up the prerequisites
1. Download and validate the Quotes app codebase
1. Use Gemini CodeAssist to explain the Quotes app, perform code reviews, translate code
1. Following **test-driven development** guidelines, use Gemini Code Assist to add business logic
1. Build and deploy the updated Quotes app to Cloud Run
1. Test the application in Cloud Run



## Challenges

- Challenge 1: Clone the Quotes app
   - Get started with your GCP project and clone the repository to edit within your environment.
- Challenge 2: Get started with Gemini Code Assist
   - Experiment with prompt engineering to understand the Gemini Code Assist feature.
- Challenge 3: Test-Driven Development
   - Have Gemini help you to add business logic using test-driven development guidelines.
- Challenge 4: Build, deploy, and test
   - Build and deploy the updated Quotes app to Cloud Run and test the endpoint.

## Prerequisites

- Your own GCP project with Owner IAM role.
- Experience with Java and Git 
- gCloud CLI
- Visual Studio Code

## Contributors

- Gino Filicetti
- Murat Eken
- Dan Dobrin
- Yanni Peng
- Daniella Noronha

## Challenge 1: Clone the Quotes app

### Pre-requisites 

- Experience with Java and Git 
- Experience with Spring Boot and Maven

### Description

In this challenge, you will set up the provided repository in your own GCP project so that you can edit in within the Cloud Shell editor and use the Gemini Code Assist plugin and chat, all without leaving GCP. Before cloning your repository, ensure you have Java and OpenJDK installed, and enable the Gemini Code Assist, Cloud Build, Cloud Run, and Cloud Logging APIs within your project. 

The Quotes repository is [found on GitHub here](https://github.com/GoogleCloudPlatform/serverless-production-readiness-java-gcp). 

### Success Criteria

- Set up your project prerequisites. 
- Verify that the Quotes app is cloned within your Google Cloud project. 
- Demonstrate your understanding of how to call Gemini Code Assist within the Quotes repository. 

### Learning Resources

- [Cloning a repository](https://cloud.google.com/source-repositories/docs/cloning-repositories)
- [Cloud Shell Editor interface overview](https://www.youtube.com/watch?v=dQw4w9WgXcQ)
- [Code with Gemini Code Assist](https://cloud.google.com/code/docs/shell/write-code-gemini#:~:text=In%20the%20activity%20bar%20of,an%20explanation%20of%20your%20code)

## Challenge 2: Get started with Gemini Code Assist

### Pre-requisites 

- Complete Challenge 1

### Introduction 

With a solid starting point for the Quotes app, it is time to build new business functionality using a test-driven development process assisted by Duet AI.
First, get a good understanding of what the Quotes application is currently doing, as well as a sense of how to prompt Gemini Code Assist. 
### Description
In this challenge, you'll seek to get comfortable using Gemini Code Assist. Design your prompts to explain the current Quotes application, get a full code review and description, and see if Gemini Code Assist can translate your code into a different language. 

> **Note**  
> Occasionally, we have to refine the request and account for the fact that GenAI tooling is non-deterministic. If the generated code did not generate the full output you're expecting, you can seek to refine it by asking more specifically for what you want or asking for more details or going step-by-step.


### Success Criteria

- Demonstrate your understanding of the Quotes application 
- Show Gemini Code Assist in action and understand how to refine prompts 

### Learning Resources

- [Write better prompts for Gemini in Google Cloud](https://cloud.google.com/gemini/docs/discover/write-prompts)

## Challenge 3: Test-Driven Development

### Pre-requisites 

- Complete Challenge 2

### Introduction 

Now that we understand the existing Quotes application, we'll seek to use test-driven development to add the additional method applying the business logic that your team is requesting. 

### Description
In this challenge, your team is asking you to enhance the existing Book Quotes application by adding new business functionality to retrieve quotes from books, given the book name. The Quotes app is missing this endpoint to retrieve book information by book name. This endpoint should respond on the “/quotes/book/{book}” path. You are being asked to implement it, with the associated business logic.

To add the quote retrieval by book name functionality, you start writing code in true TDD fashion by adding tests to both the QuotesControllerTest (for the endpoint) and QuotesRepositoryTest (for data retrieval from the database). Once you've used Gemini to help you add these tests, you should run them to demonstrate that your code works as expected.


### Success Criteria

- Have the tests for the getbyBook method written within the QuotesControllerTest and the QuotesRepositoryTest class
- Have the getByBook method written within the QuotesController class, and the findbyBook method for the QuoteRepository class
- Demonstrate that all existing and new tests pass and that the getByBook method works as expected


### Learning Resources

- [Test-driven development](https://en.wikipedia.org/wiki/Test-driven_development)

## Challenge 4: Build, deploy, and test

### Pre-requisites 

- Complete Challenge 3

### Introduction 

Finally, let's build and deploy the image so that your team can use it. 
### Description
In this challenge, you will use Cloud Build to build and deploy your container image to Cloud Run. Cloud Build supports a simple build, tag, push process in a single YAML file. The YAML file is written for you in the repository. You'll need to submit the build to Cloud Build and use Cloud Run to deploy the container image.


### Success Criteria

- Have your container image built and pushed to Cloud Build
- Have your container image deployed to Cloud Run
- Ensure your tests pass using the new endpoint for your application

### Learning Resources

- [Build and push a Docker image with Cloud Build](https://cloud.google.com/build/docs/build-push-docker-image)
- [Deploy a container image to Cloud Run](https://cloud.google.com/run/docs/quickstarts/deploy-container)


