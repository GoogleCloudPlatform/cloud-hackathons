# gHacking with Gemini CodeAssist

## Introduction

Imagine this: you are a software engineer for Project Gutenberg. Your team is asking you to enhance the existing Book Quotes application by adding new business functionality to retrieve quotes from books, given the book name. As you don’t have any prior experience with the Quotes service, you enlist the help of your trusted developer assistant, Gemini Code Assist, to understand the service, add the required functionality and write proper tests.

You choose to follow a test-driven development process, relying on requirements being converted to test cases before the service is fully developed. You track the development by repeatedly testing the service against all test cases, first in your local environment, then in a Serverless environment in GCP. 

## Learning Objectives

In this gHack you will learn how to add business functionality to an existing Java and Spring Boot serverless application using the Gemini CodeAssist feature. 

1. Set up the prerequisites
1. Download and validate the Quotes app codebase
1. Use Gemini CodeAssist to explain the Quotes app, perform code reviews, translate code
1. Following **test-driven development** guidelines, use Gemini Code Assist to add business logic
1. Build and deploy the updated Quotes app to Cloud Run
1. Test the application in Cloud Run
1. Add functionality using GenAI



## Challenges

- Challenge 1: Clone the Quotes app
   - Get started with your GCP project and clone the repository to edit within your environment.
- Challenge 2: Get started with Gemini Code Assist
   - Experiment with prompt engineering to understand the Gemini Code Assist feature.
- Challenge 3: Test-Driven Development
   - Have Gemini help you to add business logic using test-driven development guidelines.
- Challenge 4: Build, deploy, and test
   - Build and deploy the updated Quotes app to Cloud Run and test the endpoint.
- Challenge 5: Enhancing the Quotes app with GenAI
   - Use Google's GenAI capabilities to enhance the application. 

## Prerequisites

- Your own GCP project with Owner IAM role.
- Experience with Java and Git 
- gCloud CLI
- Visual Studio Code
- MacOS or Windows 

## Contributors

- Gino Filicetti
- Murat Eken
- Dan Dobrin
- Yanni Peng
- Daniella Noronha

## Challenge 1: Clone the Quotes app

### Pre-requisites 

- Java 21
- Git
- Experience with Java and Git 
- Experience with Spring Boot and Maven

### Description

In this challenge, you will set up the provided repository in your own GCP project so that you can edit in within the Cloud Shell editor and use the Gemini Code Assist plugin and chat, all without leaving GCP. Before cloning your repository, ensure you have Java and OpenJDK installed, and enable the Gemini Code Assist, Cloud Build, Cloud Run, and Cloud Logging APIs within your project. 

The Quotes repository is [found on GitHub here](https://github.com/ddobrin/quotes-workshop). 

### Success Criteria

- Set up your project prerequisites. 
- Verify that the Quotes app is cloned within your Google Cloud project. 
- Demonstrate your understanding of how to call Gemini Code Assist within the Quotes repository. 
- Run the Quotes app locally. 


### Learning Resources

- [Cloning a repository](https://cloud.google.com/source-repositories/docs/cloning-repositories)
- [Cloud Shell Editor interface overview](https://www.youtube.com/watch?v=dQw4w9WgXcQ)
- [Code with Gemini Code Assist](https://cloud.google.com/code/docs/shell/write-code-gemini#:~:text=In%20the%20activity%20bar%20of,an%20explanation%20of%20your%20code)

## Challenge 2: Get started with Gemini Code Assist

### Introduction 

With a solid starting point for the Quotes app, it is time to enhance the code base.  

### Description
In this challenge, you'll seek to get comfortable using Gemini Code Assist. Design your prompts to explain the current Quotes application, get a full code review and description, and see if Gemini Code Assist can translate your code into a different language. 

> **Note**  
> Occasionally, we have to refine the request and account for the fact that GenAI tooling is non-deterministic. If the generated code did not generate the full output you're expecting, you can seek to refine it by asking more specifically for what you want or asking for more details or going step-by-step.
First, get a good understanding of what the Quotes application is currently doing, as well as a sense of how to prompt Gemini Code Assist. Then, start by adding comments to each method. The code base is poorly documented, so this will help your team understand each method and ensure that anything they add is useful and not duplicated. 

Next, use the debugging features of Gemini. There is a potential NullPointerException error in the UpdateQuote method: use Gemini to locate this and solve it. 

We can also use Gemini to generate an OpenAPI spec for all the operations in the QuoteController.java class. Go ahead and prompt Gemini to generate this and save it as a YAML file within the repository. 


### Success Criteria

- Be able to give a detailed overview of the Quotes application: what are the use cases? What might be missing or could be improved? Gemini can help you decide
- Explain the methods within the QuoteController class and show an OpenAPI spec for all the operations
- Find and fix the bug within the UpdateQuote method


### Learning Resources

- [Write better prompts for Gemini in Google Cloud](https://cloud.google.com/gemini/docs/discover/write-prompts)

## Challenge 3: Test-Driven Development

### Introduction 
Now that we understand the existing Quotes application, we'll seek to use test-driven development to add the additional method applying the business logic that your team is requesting. 

### Description
In this challenge, your team is asking you to enhance the existing Book Quotes application by adding new business functionality to retrieve quotes from books, given the book name. The Quotes app is missing this endpoint to retrieve book information by book name. This endpoint should respond on the “/quotes/book/{book}” path. You are being asked to implement it, with the associated business logic.

To add the quote retrieval by book name functionality, you start writing code in true TDD fashion by first adding tests to both the QuotesControllerTest (for the endpoint) and QuotesRepositoryTest (for data retrieval from the database). Once you've defined the test criteria, you can then add the relevant methods. Once you've used Gemini to help you add this code, you should run the tests to demonstrate that your code works as expected.


### Success Criteria

- Have the tests for the getbyBook method written within the QuotesControllerTest and the QuotesRepositoryTest class
- Have the getByBook method written within the QuotesController class, and the findbyBook method for the QuoteRepository class
- Demonstrate that all existing and new tests pass and that the getByBook method works as expected


### Learning Resources

- [Test-driven development](https://en.wikipedia.org/wiki/Test-driven_development)

## Challenge 4: Build, deploy, and test

### Introduction 

Finally, let's build and deploy the image so that your team can use it. 

### Description
In this challenge, you will use Cloud Build to build and deploy your container image to Cloud Run. Cloud Build supports a simple build, tag, push process in a single YAML file. The YAML file is available in the repository. You'll need to fill in the missing methods, and then submit the build to Cloud Build. Finally, you'll need to deploy your container image to Cloud Run.

Remember that Gemini Code Assist can always help out if you're unfamiliar with a file or need some suggestions on how to get started with or improve your code.
### Success Criteria

- Have your container image built and pushed to Cloud Build
- Have your container image deployed to Cloud Run
- Ensure your tests pass using the new endpoint for your application

### Learning Resources

- [Build and push a Docker image with Cloud Build](https://cloud.google.com/build/docs/build-push-docker-image)
- [Deploy a container image to Cloud Run](https://cloud.google.com/run/docs/quickstarts/deploy-container)


## Challenge 5: Enhancing the Quotes app with GenAI

### Introduction 

Now that we have a successful, working application, let's see how we can use Google's GenAI capabilities to enhance it. 

### Description
Let's introduce GenAI to the application, using the PaLM 2 Text Bison API. The PaLM 2 for Text (text-bison, text-unicorn) foundation models are optimized for a variety of natural language tasks such as sentiment analysis, entity extraction, and content creation.

You will see the skeleton method within the GenerateQuote.java file. This method should take in the name of a book, entered by the user, and prompt Gemini to come up with an appropriate quote. As always, lean on your Gemini chat and code generation to help produce the correct code and refine the prompts as needed. 
 
Once the method is completed, you can rebuild the app, redeploy and test in Cloud Run.

### Success Criteria

- Deploy an endpoint that generates new quotes using PaLM 2 for Text instead of pulling from the database
- Have your container image rebuilt and pushed to Cloud Build
- Have your new container image re-deployed to Cloud Run
- Ensure your tests pass using the new endpoint for your application

### Learning Resources

- [PaLM 2 for Text](https://cloud.google.com/vertex-ai/generative-ai/docs/model-reference/text)
