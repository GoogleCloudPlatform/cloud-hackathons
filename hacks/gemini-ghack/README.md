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
- An AVNET X231 device
- gCloud CLI
- Visual Studio Code

## Contributors

- Gino Filicetti
- Murat Eken
- Dan Dobrin
- Yanni Peng
- Daniella Noronha

## Challenge 1: Clone the Quotes app

***This is a template for a single challenge. The italicized text provides hints & examples of what should or should NOT go in each section.  You should remove all italicized & sample text and replace with your content.***

_You can use these two specific blockquote styles to emphasize your text as needed and they will be specially rendered to be more noticeable_
> **Note**  
> Sample informational blockquote

> **Warning**  
> Sample warning blockquote

### Pre-requisites (Optional)

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

> **Note**  
> Sample informational blockquote

> **Warning**  
> Sample warning blockquote

### Pre-requisites 

- Complete Challenge 1

### Introduction 

With a solid starting point for the Quotes app, it is time to build new business functionality using a test-driven development process assisted by Duet AI.
First, get a good understanding of what the Quotes application is currently doing, as well as a sense of how to prompt Gemini Code Assist. 
### Description
In this challenge, you'll seek to get comfortable using Gemini Code Assist. 


### Success Criteria

- Demonstrate your understanding of the Quotes application 
- Show Gemini Code Assist in action and understand how to refine prompts 

### Tips

*This section is optional and may be omitted.*

*Add tips and hints here to give students food for thought. Sample IoT tips:*

- IoTDevices can fail from a broken heart if they are not together with their thingamajig. Your device will display a broken heart emoji on its screen if this happens.
- An IoTDevice can have one or more thingamajigs attached which allow them to connect to multiple networks.

### Learning Resources

- [What is a Thingamajig?](https://www.google.com/search?q=what+is+a+thingamajig)
- [Cloud Shell Editor interface overview](https://www.youtube.com/watch?v=dQw4w9WgXcQ)
- [IoT & Thingamajigs: Together Forever](https://www.youtube.com/watch?v=yPYZpwSpKmA)

