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
- They upload the entry (embedding and other fields) into the **movies** table.

## Challenge 2: Create a prompt for the UserProfileFlow to extract strong preferences and dislikes from the user's statement

### Notes & Guidance
Example prompt that meets the success criteria:
```
		 You are a user's movie profiling expert focused on uncovering users' enduring likes and dislikes. 
     Your task is to analyze the user message and extract ONLY strongly expressed, enduring likes and dislikes related to movies.
     Once you extract any new likes or dislikes from the current query respond with the items you extracted with:
		  1. the category (ACTOR, DIRECTOR, GENRE, OTHER)
		  2. the item value
		  3. your reason behind the choice
		  4. the sentiment of the user has about the item (POSITIVE, NEGATIVE).
		
      Guidelines:
      1. Strong likes and dislikes Only: Add or Remove ONLY items expressed with strong language indicating long-term enjoyment or aversion (e.g., "love," "hate," "can't stand,", "always enjoy"). Ignore mild or neutral items (e.g., "like,", "okay with," "fine", "in the mood for", "do not feel like").
      2. Distinguish current state of mind vs. Enduring likes and dislikes:  Be very cautious when interpreting statements. Focus only on long-term likes or dislikes while ignoring current state of mind. If the user expresses wanting to watch a specific type of movie or actor NOW, do NOT assume it's an enduring like unless they explicitly state it. For example, "I want to watch a horror movie movie with Christina Appelgate" is a current desire, NOT an enduring preference for horror movies or Christina Appelgate.
      3. Focus on Specifics:  Look for concrete details about genres, directors, actors, plots, or other movie aspects.
      4. Give an explanation as to why you made the choice.
        
		Inputs: 
		1. Optional Message 0 from agent: {{agentMessage}}
		2. Required Message 1 from user: {{query}}
```

### Anatomy of the prompt:
**1. Role Definition:**

> You are a user's movie profiling expert focused on uncovering users' enduring likes and dislikes. 

* **Purpose:** Clearly defines the LLM's role and expertise.

**2. Task Instruction:**

> Your task is to analyze the user message and extract ONLY strongly expressed, enduring likes and dislikes related to movies.

* **Purpose:** Specifies the primary goal and scope of the task.

**3. Output Format:**

> Once you extract any new likes or dislikes... respond with the items you extracted with:
>
> 1. the category (ACTOR, DIRECTOR, GENRE, OTHER)
> 2. the item value
> 3. your reason behind the choice
> 4. the sentiment of the user has about the item (POSITIVE, NEGATIVE).

* **Purpose:**  Provides a structured format for the LLM's response.

**4. Guidelines:**

> Guidelines:
>
> 1. Strong likes and dislikes Only: ... (examples provided)
> 2. Distinguish current state of mind vs. Enduring likes and dislikes: ... (example provided)
> 3. Focus on Specifics: ...
> 4. Give an explanation as to why you made the choice.

* **Purpose:** Offers detailed instructions and clarifications to guide the LLM's analysis.

**5. Input Specification:**

> Inputs: 
>
> 1. Optional Message 0 from agent: {{agentMessage}}
> 2. Required Message 1 from user: {{query}}

* **Purpose:** Clearly defines the expected input data and its structure.

## Challenge 3: Create a prompt and flow for the QueryTransformFlow to create a query for the vector database


### Notes & Guidance
Example prompt that meets the success criteria:

```
		You are a search query refinement expert.  Do NOT answer the user's question directly. Instead, create the best query for a vector search engine to find relevant information, considering the conversation history and user preferences.

		Instructions:

		1. Analyze the conversation history {{history}} to understand the context and main topics. Focus on the user's most recent request.

		2.  Use the user profile ({{userProfile}}) when relevant:
			*   Include strong likes if they align with the query.
			*   Include strong dislikes only if they conflict with or narrow the request.
			*   Ignore irrelevant likes or dislikes.

		3. Prioritize the user's current request ({{userMessage}}) as the core of the search query.

		4. Keep the query concise and specific.

		Respond with the following:

		*   a *justification* about why you created the query this way.
		*   the *transformedQuery* which is the resulting refined search query.
		*   a *userIntent*, which is one of GREET, END_CONVERSATION, REQUEST, RESPONSE, ACKNOWLEDGE, UNCLEAR
```

Sample code that implements the flow:

```go
func GetQueryTransformFlow(ctx context.Context, model ai.Model, prompt string) (*genkit.Flow[*types.QueryTransformFlowInput, *types.QueryTransformFlowOutput, struct{}], error) {

	queryTransformPrompt, err := dotprompt.Define("queryTransformFlow",
		prompt,

		dotprompt.Config{
			Model:        model,
			InputSchema:  jsonschema.Reflect(types.QueryTransformFlowInput{}),
			OutputSchema: jsonschema.Reflect(types.QueryTransformFlowOutput{}),
			OutputFormat: ai.OutputFormatJSON,
			GenerationConfig: &ai.GenerationCommonConfig{
				Temperature: 0.5,
			},
		},
	)
	if err != nil {
		return nil, err
	}
	// Define a simple flow that prompts an LLM to generate menu suggestions.
	queryTransformFlow := genkit.DefineFlow("queryTransformFlow", func(ctx context.Context, input *types.QueryTransformFlowInput) (*types.QueryTransformFlowOutput, error) {
		
    // Default output
		queryTransformFlowOutput := &types.QueryTransformFlowOutput{
			ModelOutputMetadata: &types.ModelOutputMetadata{
				SafetyIssue:   false,
				Justification: "",
			},
			TransformedQuery: "",
			Intent:           types.USERINTENT(types.UNCLEAR),
		}

    // Generate model output
		resp, err := queryTransformPrompt.Generate(ctx,
			&dotprompt.PromptRequest{
				Variables: input,
			},
			nil,
		)
    //[OPTIONAL] Capture any safety issues and handle them differently.
		if err != nil {
			if blockedErr, ok := err.(*genai.BlockedError); ok {
				log.Println("Request was blocked:", blockedErr)
				queryTransformFlowOutput = &types.QueryTransformFlowOutput{
					ModelOutputMetadata: &types.ModelOutputMetadata{
						SafetyIssue: true,
					},
					TransformedQuery: "",
				}
				return queryTransformFlowOutput, nil

			} else {
				return nil, err
			}
		}

    // Transform the model's output into the required format.
		t := resp.Text()
		err = json.Unmarshal([]byte(t), &queryTransformFlowOutput)
		if err != nil {
			return nil, err
		}

		return queryTransformFlowOutput, nil
	})
	return queryTransformFlow, nil
}
```