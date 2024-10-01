# AI App hack

## Introduction

This hack helps you create and deploy a GenAI application (see below) using Google Cloud and Firebase Genkit.
You do the following:
- Part1: Add data into the vector database.
- Part1: Creating GenAI flows that power this app.
- Part1: Building security and validation into model responses.
- Part1: Run this application locally.
- Part2: Make this a fully cloud based application (Deploy the application on GCP) using firebase, cloudrun, memory store for redis.

[![Movie Guru](https://img.youtube.com/vi/l_KhN3RJ8qA/0.jpg)](https://youtu.be/l_KhN3RJ8qA)

## Learning Objectives

In this hack you will learn how to: 
- Part 1:
   1. Vectorise a simple dataset and add it to a vector database (postgres PGVector).
   1. Create a flow using genkit that anaylses a user's statement and extract's their long term preferences and dislikes.
   1. Create a flow using genkit that summarises the conversation with the user and transform's the user's latest query by adding context.
   1. Create a flow using genkit that takes the transformed query and retrieves relevant documents from the vector database.
   1. Create a flow using genkit that takes the retrieved documents, conversation history and the user's latest query and formulates a relevant response to the user.
- Part 2:
  The Postgres DB, the Redis memory store, Artifact Registry are already created for you.
  1. You will learn how to build containers in the cloud and store them in an artifact registry.
  1. You will learn to deploy the frontend in firebase.
  1. You will learn to deploy the webserver and the genkit flow server into cloud run.
  1. You will learn how to communicate with the database and the redis instance over a private network.

## Challenges

- Challenge 1: Upload the data to the vector database
   - Create an embedding for each entry in the dataset (discussed later), and upload the data to a vector database using the predefined schema. Do this using a genkit flow.
- Challenge 2: Your first flow that analyses the user's input.
   - Create a flow that takes the user's latest input and make sure you extract *any* long term preference or dislike. 
- Challenge 3: Flow that analyses the converstation history and transforms the user's latest query with the relevant context.
- Challenge 4: Retrieve the relevant documents from the transformed context created at the previous challenge.
- Challenge 5: Create a meaningful response to the user (RAG flow).
   - Select the relevant outputs from the previous stages and return a meaningful output to the user.

## Prerequisites

- Your own GCP project with Owner IAM role.
- gCloud CLI 
- gCloud CloudShell terminal (cannot get the front end to talk to the rest of the components) **OR**
- RECOMMENDED: Local IDE (like VSCode) with [Docker](https://docs.docker.com/engine/install/) and [Docker Compose](https://docs.docker.com/compose/install/)  

**Cloud Shell Terminal** will let you get through all the exercises, but it is complex to work with the frontend (vue app).

## Contributors

- Gino Filicetti
- Murat Eken
- Manasa Kandula
- Christiaan Hees

## Setup
This should take approximately **15 minutes**.

Open your project in the GCP console, and open a **cloud shell editor**. This should open up a VSCode-like editor. Make it full screen if it isn't already.
Step 1:
    - Open a terminal from the editor (Hamburgermenu > terminal > new terminal). 
    - Check if the basic tools we need are installed. Run the following command.
```sh
docker compose version
```
If it prints out a version number you are good to go.

Step 2:
 - Open another GCP console for this project and look for **SQL**. You should see a DB called **movie-guru-db-instance**.
 - Go to **Secret Manager**. You should see 2 secrets here.

Step 3:
 - Open the IDE (or **Cloud Shell Editor**).
 - Clone the repo and naviagate to the folder.
```sh
git clone https://github.com/MKand/movie-guru.git --branch test-ghack
cd movie-guru
```
 - Re-open the IDE with the folder movie-guru as the current workspace.

Step 4: 
- Open the **set_env_vars.sh** file (found at the root of the repo folder).
- Copy the value of the **postgres-main-user-password** and **postgres-minimal-user-password** and replace them in the **set_env_vars.sh** file and replace them under   **POSTGRES_DB_MAIN_USER_PASSWORD** and **POSTGRES_DB_USER_PASSWORD** respectively.
- Copy the **PROJECT ID** (not PROJECT name) and replace it in the **set_env_vars.sh** under **PROJECT_ID**.
- Go the **movie-guru-db-instance** instance and copy down the public IP address. Replace it in the **set_env_vars.sh** under **POSTGRES_HOST**.
- Save the **set_env_vars.sh** file.
- Load the env variables into the current terminal by running the following command.
```sh
source set_env_vars.sh
```

Step 5:
 Connect to the sql db through the **Cloud SQL Studio**.
 - We will use the **main** user for this step. 
 - Log into the **Cloud SQL Studio** from the GCP console with the credentials of the main user.
 
Step 6:

 Create the necessary tables and add permissions to the minimal-user.
Run the following SQL queries in the editor of **Cloud SQL Studio**
```SQL
CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE IF NOT EXISTS movies (
    tconst VARCHAR PRIMARY KEY,
    embedding VECTOR(768),
    title VARCHAR,
    runtime_mins INTEGER,
    genres VARCHAR,
    rating NUMERIC(3, 1),
    released INTEGER,
    actors VARCHAR,
    director VARCHAR,
    plot VARCHAR,
    poster VARCHAR,
    content VARCHAR
);

CREATE TABLE user_preferences (
  "user" VARCHAR(255) NOT NULL, 
  preferences JSON NOT NULL,
  PRIMARY KEY ("user")
);

GRANT SELECT ON movies TO "minimal-user";
GRANT SELECT, INSERT, UPDATE, DELETE ON user_preferences TO "minimal-user";
```

Step 7:
* Go to the project in the GCP console. Go to **IAM > Service Accounts**. 
* Select the movie guru service account (movie-guru-chat-server-sa@<project id>.iam.gserviceaccount.com). * Create a new JSON key. 
* Download the key and store it as **.key.json** in the root of this repo (make sure you use the filename exactly). 

Now you are ready to start the challenges.

## Challenge 1: Upload the data to the vector database
This is one of the most complex challenges in Part1. This should take approximately **45 minutes**.

### Introduction
The goal of challenge 1 is to insert this data, along with the vector embeddings into the **movie-guru-db-instance** DB, under the table **movies**.
This includes creating an embedding per movie, and uploading the remainder of the metadata into each row.
You need to perform the following steps:
1. Open the file **dataset/movies_with_posters.csv** and review it. This file contains the AI Generated movie details used in application.
1. Select appropriate fields in the raw data for each movie that are useful to use in a vector search. These are factors users would typically use when looking for movies.
1. Create an embedding per movie based on the fields you selected before.
1. Upload each movie into the **movies** table. The schema is given below. You might need to reformat some columns in raw data columns.
1. Structure each entry (embedding and metadata) into the format required by the table. 

You can do this with *GoLang* or *Javascript*. Refer to the specific sections on how to continue. 

### Pre-requisites 
Make sure you have finished the **Setup**.

### GoLang
Look at the **chat_server_go/pkg/flows/indexer.go** file. This module is called by **chat_server_go/cmd/indexer/main.go**
You'll need to edit **chat_server_go/pkg/flows/indexer.go** file to upload the required data successfully.
There are hints in the file to help you proceed. 

- Once you think you have accomplished what you need to do, run the following to start the indexer and let it upload data to the **movies** table. You can always run it intermediately if you want to verify something.  
```sh
docker compose -f docker-compose-indexer.yaml up --build
```
- (OPTIONAL) If at any stage you want to clear the table because you made a mistake, you can run the following command in **Cloud SQL Studio**
```SQL
TRUNCATE TABLE movies;
```
- If you are successful, there should be a total of **652** entries in the table.
- Once finished run the following command to close the indexer. You won't need it anymore for other challenges.
```sh
docker compose -f docker-compose-indexer.yaml down
```

### JS
WIP

### Description
*The movies table has the following schema:
| Column Name | Data Type | Allows Nulls? | Notes |
|---|---|---|---|
| rating | numeric | YES | Value from 0 to 5  |
| released | integer | YES | Year of release  |
| runtime_mins | integer | YES |  |
| director | character varying | YES | Each movie has a single director |
| plot | character varying | YES |  |
| poster | character varying | YES | URL of poster |
| tconst | character varying | NO | ID of the movie,  borrowed from IMDB |
| content | character varying | YES |  |
| title | character varying | YES |  |
| genres | character varying | YES | Comma seperated strings |
| actors | character varying | YES | Comma seperated strings |
| embedding | USER-DEFINED | YES | Stores vector embeddings of the movies. |

### Success Criteria
* The **movies** table contains **652** entries. You can verify this by running the following command in the **Cloud SQL Studio**:

```SQL
SELECT COUNT(*)
FROM "movies";
```
* Each entry should contain a vector embedding in the **embedding** field.
* The other fields in the schema should also be present and meaningful.

### Learning Resources
- [Example Implementation Indexer](https://github.com/firebase/genkit/blob/main/go/samples/pgvector/main.go)
- [GenKit Indexer](https://firebase.google.com/docs/genkit-go/rag#define_an_indexer)
- [GenKit PGVector](https://firebase.google.com/docs/genkit-go/pgvector)


## Challenge 2: Create a prompt for the UserProfileFlow to extract strong preferences and dislikes from the user's statement

### Introduction
This is your first prompt engineering challenge. The goal of this prompt is to create the prompt required to extract strong preferences and dislikes from the user's statement.

We want the model to take a user's statement, and potentially the agent's previous statement (if there is one) and extract the following:
1. **List of recommendations** from the model about what it expects the user really likes or dislikes based on the user's latest statement. Each recommendation contains the following information:
    - **Item**: The (movie related) item the user expressed a strong sentiment about. Eg: A genre, an actor, director etc.
    - **Reason**: The justification from the model to have extracted that specific item.
    - **Category**: The category of the item. Eg: Genre, Actor, Director, or Other.
    - **Sentiment**: The user's sentiment about the item. **Positive** or **Negative**. 
2. **Explanation**: General explanation of the overall output. This will help you understand why the model made its suggestions and help you debug and improve your prompt.

You need to perform the following steps:
1. Create a prompt that outputs the information mentioned above. The model takes in a user's query and a preceeding agentMessage (if present).
1. Update the prompt in the codebase (look at instructions in GoLang or JS) to see how.
1. Use the genkit UI (see steps below) to test the response of the model and make sure it returns what you expect.

You can do this with *GoLang* or *Javascript*. Refer to the specific sections on how to continue. 

### Pre-requisites 

#### GoLang
Genkit provides a CLI and a GUI that work together to help you develop and manage generative AI components. They are tools designed to streamline your workflow and make building with LLMs more efficient. 
When you start the genkit GUI, it starts up your flow server locally (go to **chat_server_go/cmd/flows/main.go**). You should see code that looks like this:
```go
	if err := genkit.Init(ctx, &genkit.Options{FlowAddr: ":3401"}); err != nil {
		log.Fatal(err)
	}
```
When you run **genkit start**  directory where your genkit server code is located  (**chat_server_go/cmd/flows/main.go**), it starts up the genkit flows server defined in your Go code, and a GUI to interact with the GenAI components defined in your code.
The [normal workflow](https://firebase.google.com/docs/genkit-go/get-started-go) is to install the necessary components on your local machine. Given that this lab have minimal (pre) setup requirements (only docker and docker compose), we choose to run the genkit CLI and GUI through a container which adds a couple of extra setup steps, but ensures consistency across different lab setups. 

For this challenge, you do not need to have the app running, we are just going to work with the flows.
From the root of the project directory run the following.
```sh
docker compose up -d genkit-go # running just the genkit-go service
```
Once the service has started up, we are going to exec into the container. The reason we are not using **genkit start** as a startup command is that it has an interactive step at startup that cannot be bypassed. 
So, we will exec into the container and then run the command **genkit start**. 
```sh
docker compose exec genkit-go sh
```
This should open up a shell inside the container at the location **/app/cmd/flows**. 
**NOTE**: In the docker compose file, we mount the local directory **chat_server_go/cmd/flows** into the container at **app/cmd/flows**, so that we can make changes in the local file system, while still being able to execute genkit tools from a container.
Inside the container, run
```sh
genkit start
```

You should see something like this
```
Genkit CLI and Developer UI use cookies and similar technologies from Google
to deliver and enhance the quality of its services and to analyze usage.
Learn more at https://policies.google.com/technologies/cookies
Press "Enter" to continue
```
Then press **ENTER** as instructed (this is the interactive step mentioned earlier).
This should start the genkit server inside the container at port 4000 which we forward to port 4001 to your host machine (in the docker compose file).

You should see in the left-hand pane of the UI that there are 4 flows, 3 prompts and 1 retriever loaded. If that is the case you are good to go.

Navigate to http://localhost:4001 in your browser. This will open up the **Genkit UI**.
**Note: Potential error message**: At first, the genkit ui might show an error message and have no flows or prompts loaded. This might happen if genkit wasn't able to detect the local files. If that happens,  go to **chat_server_go/cmd/flows/main.go**, make a small change (add a newline) and save it. This will cause the files to be detected.

#### JS
WIP

### Description
#### GoLang
1. Go to **chat_server_go/cmd/flows/main.go**. You should see code that looks like this in the method **getPrompts()**. 
```golang
userProfilePrompt :=
		`
		Inputs: 
		1. Optional Message 0 from agent: {{agentMessage}}
		2. Required Message 1 from user: {{query}}

		Just say hi in a language you know.
		`
```
1. Keep this file (main.go) open in the editor. You will be editing the prompt here, and testing it in the **genkit UI**.
2. From the Genkit UI, go to **Prompts/dotprompt/userProfileFlow**. 
3. You should see an empty input to the prompt that looks like this:

```json
{
    "query": "",
    "agentMessage": ""
}
```

4. You should also see a prompt (the same prompt in main.go) below. You need to edit this prompt in **main.go** but can test it out by changing the input, model and other params in the UI.
5. Test it out: Add a query "I want to watch a movie", and leave the agentMessage empty and click on **RUN**. 
6. The model should respond by greeting you in a random language (this is what the prompt asks it to do). 
7. You need to rewrite the prompt (in main.go) and test the model's outputs for various inputs such that it does what it is required to do (refer to the goal of challenge 2). Edit the prompt in **main.go** and **save** the file. The updated prompt should show up in the UI. If it doesn't just refresh the UI. You can also play around with the model parameters. 

### JS
WIP

### Success Criteria
**Criteria 1**: The model should be able to extract the user's sentiments from the message.
**Criteria 2**: The model should be able output all the required fields with the correct values (see introduction to). 
The input of:
```json
{
    "agentMessage": "",
    "query": "I really like comedy films."
}
```
Should return a model output like this:
```
## New Profile Item:
**Category:** GENRE 
**Item Value:** Comedy
**Reason:** The user explicitly states "I really like comedy films," indicating a strong and enduring preference for this genre.
**Sentiment:** POSITIVE 
```
**Criteria 3**: The model should be able to pick up categorise sentiments as Postive and Negative.  
The input of:
```json
{
    "agentMessage": "",
    "query": "I really hate comedy films."
}
```
Should return a model output like this:
```
## New Profile Item:
**Category:** GENRE 
**Item:** Comedy 
**Reason:** The user explicitly states "I really hate comedy films."  This indicates a strong, enduring dislike for the genre. 
**Sentiment:** NEGATIVE 
```
**Criteria 4**: The model should ignore weak/temporary sentiments.  
The input of:
```json
{
    "agentMessage": "",
    "query": "I feel like watching a movie with Tom Hanks."
}
```
Should return a model output (something) like this:
```
I cannot extract any new likes or dislikes from this user message. The user is expressing a current desire to watch a movie with Tom Hanks, but this does not necessarily indicate a long-term preference for him. The user may simply be in the mood for a Tom Hanks film right now, without actually having a strong enduring like for his movies.
```

**Criteria 5**: The model should be able to pick up multiple sentiments.  
The input of:
```json
{
    "agentMessage": "",
    "query": "I really hate comedy films but love Tom Hanks."
}
```
Should return a model output like this:
```
Here's the breakdown of the user's message:
**Extracted Profile Items:**
* **Category:** GENRE
* **Item:** Comedy
* **Reason:** The user explicitly states "I really hate comedy films."
* **Sentiment:** NEGATIVE

* **Category:** ACTOR
* **Item:** Tom Hanks
* **Reason:** The user explicitly states "love Tom Hanks."
* **Sentiment:** POSITIVE

**Explanation:**
The user expresses strong, enduring feelings about both comedy films and Tom Hanks.  "Really hate" and "love" indicate strong, long-term preferences. 
```
**Criteria 6**: The model can infer context
```json
{
    "agentMessage": "I know of 3 actors: Tom Hanks, Johnny Depp, Susan Sarandon",
    "query": "Oh! I really love the last one."
}
```
Should return a model output like this:
```
## New Profile Item:
**Category:** ACTOR 
**Item:** Susan Sarandon
**Reason:** The user explicitly states "I really love the last one," referring to Susan Sarandon, indicating a strong and enduring liking.
**Sentiment:** POSITIVE 
```
### Learning Resources
- [Genkit Prompts](https://firebase.google.com/docs/genkit-go/prompts)
- [Prompt Engineering](https://www.promptingguide.ai/)
- [Genkit UI and CLI](https://firebase.google.com/docs/genkit/devtools)

## Challenge 3: Create a flow that analyses the conversation history and transforms the user’s latest query with the relevant context.

### Introduction
This is your second prompt engineering challenge. On top of the prompt engineering challenge, we're also going to add a second challenge to this which is to embed the prompt in a flow and get a structured output back from the flow.

We want the model to take a user's statement, the conversation history and extract the following:
1. **Transformed query**: The query that will be sent to the vector database to search for relevant documents:
2. **User Intent**: The intent of the user's latest statement. Did the user issue a greeting to the chatbot (GREET), end the conversation (END_CONVERSATION), make a request to the chatbot (REQUEST), respond to the chatbot's question (RESPONSE), ackowledge a chatbot's statement (ACKNOWLEDGE), or is it unclear (UNCLEAR). The reason we do this is to prevent a call to the vector DB if the user is not searching for anything. The application only performs a search if the intent is REQUEST or RESPONSE. 
3. Optional **Justification**:  General explanation of the overall output. This will help you understand why the model made its suggestions and help you debug and improve your prompt.

You need to perform the following steps:
1. Create a prompt that outputs the information mentioned above. The model takes in a user's query, the conversation history, and the user's profile information (long lasting likes or disklikes).
1. Update the prompt in the codebase (look at instructions in GoLang or JS) to see how.
1. Use the genkit UI (see steps below) to test the response of the model and make sure it returns what you expect.
1. After the prompt does what you expect, then update the flow to use the prompt and return an output of the type **QueryTransformFlowOutput**

You can do this with *GoLang* or *Javascript*. Refer to the specific sections on how to continue. 

### Pre-requisites 
Genkit UI and CLI running. See setup steps for challenge 2.

#### GoLang

We're going to be using the Genkit UI for the prompt engineering portion of the exercise.
Make sure you have that up and running (see challenge 2 setup).

Navigate to http://localhost:4001 in your browser. This will open up the **Genkit UI**.
**Note: Potential error message**: At first, the genkit ui might show an error message and have no flows or prompts loaded. This might happen if genkit wasn't able to detect the local files. If that happens,  go to **chat_server_go/cmd/flows/main.go**, make a small change (add a newline) and save it. This will cause the files to be detected.

#### JS
WIP

### Description
#### GoLang
1. Go to **chat_server_go/cmd/flows/main.go**. You should see code that looks like this in the method **getPrompts()**. 
```golang
queryTransformPrompt :=
		`
                    This is the user profile. This expresses their long-term likes and dislikes:
                    {{userProfile}} 

					This is the history of the conversation with the user so far:
					{{history}} 
			
					This is the last message the user sent. Use this to understand the user's intent:
					{{userMessage}}
					Translate the user's message into a different language of your choice.
		`
```
1. Keep this file (main.go) open in the editor. You will be editing the prompt here, and testing it in the **genkit UI**.
2. From the Genkit UI, go to **Prompts/dotprompt/queryTransformFlow**. 
3. You should see an empty input to the prompt that looks like this:

```json
{
    "history": [
        {
            "sender": "",
            "message": ""
        }
    ],
    "userProfile": {
        "likes": { "actors":[""], "director":[""], "genres":[], "other":[""]},
        "dislikes": {"actors":[""], "director":[""], "genres":[], "other":[""]}
    },
    "userMessage": "Hello"
}
```

4. You should also see a prompt (the same prompt in main.go) below. You need to edit this prompt in **main.go** but can test it out by changing the input, model and other params in the UI.
5. Test it out: Add a query "I want to watch a movie", and leave the rest empty and click on **RUN**. 
6. The model should respond by translating this into a random language (this is what the prompt asks it to do). 
7. You need to rewrite the prompt (in main.go) and test the model's outputs for various inputs such that it does what it is required to do (refer to the goal of challenge 2). Edit the prompt in **main.go** and **save** the file. The updated prompt should show up in the UI. If it doesn't just refresh the UI. You can also play around with the model parameters. 
8. After you get your prompt working, it's now time to get implement the flow. Navigate to  **chat_server_go/pkg/flows/queryTransform.go**.  You should see something that looks like this. What you see is that we define the dotprompt and specify the input and output format for the dotprompt. The prompt is however never invoked. We create an empty **queryTransformFlowOutput** and this will always result in the default output. You need to invoke the prompt and have the model generate an output for this. 
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

		// INSTRUCTIONS:
		// 1. Call this prompt with the necessary input and get the output.
		// 2. The output should then be tranformed into the type  QueryTransformFlowOutput and stored in the variable queryTransformFlowOutput
		// 3. Handle any errors that may arise.

		return queryTransformFlowOutput, nil
	})
	return queryTransformFlow, nil
}
```


If you run the following:
```sh
./curl-querytransform.sh
``` 
You should get something that looks like this:
```json
{
    "result": {
    "transformedQuery":"",
    "userIntent":"UNCLEAR",
    "justification":"",
    "safetyIssue":false
    }
}
```
But, once you implement the necessary code (and prompt), you should see something like this
```json
{
    "result": {
    "transformedQuery":"movie",
    "userIntent":"REQUEST",
    "justification":"The user's request is simple and lacks specifics.  Since the user profile provides no likes or dislikes, the transformed query will reflect the user's general request for a movie to watch.  No additional information is added because there is no context to refine the search.",
    "safetyIssue":false
    }
}
```
### JS
WIP

### Success Criteria
**Criteria 1**: The model should be able to extract the user's intent from the message and a meaningful query.
The input of:
```json
{
    "history": [
        {
            "sender": "agent",
            "message": "How can I help you today"
        },
        {
            "sender": "user",
            "message": "Hi"
        }
    ],
    "userProfile": {
        "likes": { "actors":[""], "director":[""], "genres":[], "other":[""]},
        "dislikes": {"actors":[""], "director":[""], "genres":[], "other":[""]}
       
    },
    "userMessage": "Hi"
    }
```
Should return a model output like this:
```json
{
  "justification": "The user's message 'hi' is a greeting and doesn't express a specific request or intent related to movies or any other topic.  Therefore, no query transformation is needed, and the userIntent is set to GREET.",
  "transformedQuery": "",
  "userIntent": "GREET"
}
```
The input of:
```json
{
    "history": [
        {
            "sender": "agent",
            "message": "I have a large database of comedy films"
        },
        {
            "sender": "user",
            "message": "Ok. Tell me about them"
        }
    ],
    "userProfile": {
        "likes": { "actors":[], "director":[], "genres":[], "other":[]},
        "dislikes": {"actors":[], "director":[], "genres":[], "other":[]}
    },
    "userMessage": "Ok. Tell me about them"
    }
```
Should return a model output like this:
```json
{
  "justification": "The user's previous message indicated an interest in comedy films.  Their current message, \"Ok. tell me about them,\" is a request for more information about the comedy films previously mentioned by the agent.  Since the user profile lacks specific likes and dislikes regarding actors, directors, or genres,  the query focuses solely on the user's expressed interest in comedy films.",
  "transformedQuery": "comedy films",
  "userIntent": "REQUEST"
}
```
The input of:
```json
{
    "history": [
        {
            "sender": "agent",
            "message": "I have a large database of comedy films"
        }
    ],
    "userProfile": {
        "likes": { "actors":[], "director":[], "genres":[], "other":[]},
        "dislikes": {"actors":[], "director":[], "genres":[], "other":[]}
    },
    "userMessage": "I'm not interested. Bye."
    }
```
Should return a model output like this:
```json
{
  "justification": "The user's last message, \"Ok. Not interested bye\", indicates they are ending the conversation after acknowledging the agent's previous message about comedy films.  There is no further query to refine.  The user's profile contains no preferences that could be used to refine a non-existent query.",
  "transformedQuery": null,
  "userIntent": "END_CONVERSATION"
}
```
The input of:
```json
{
    "history": [
        {
            "sender": "agent",
            "message": "I have a large database of comedy films"
        }
    ],
    "userProfile": {
        "likes": { "actors":[], "director":[], "genres":[], "other":[]},
        "dislikes": {"actors":[], "director":[], "genres":[], "other":[]}
    },
    "userMessage": "Ok. Good to know"
    }
```
Should return a model output like this:
```json
{
  "justification": "The user's last message, \"Ok. Good to know\", is an acknowledgement of the agent's previous statement about having many comedy films.  It doesn't represent a new request or question. The user's profile provides no relevant likes or dislikes to refine a movie search. Therefore, the transformed query will remain broad, focusing on comedy films.",
  "transformedQuery": "comedy films",
  "userIntent": "ACKNOWLEDGE"
}
```
**Criteria 2**: The model should be able to take existing likes and disklikes into account.  
The input of:
```json
{
    "history": [
        {
            "sender": "agent",
            "message": "I have many films"
        }
    ],
    "userProfile": {
        "likes": { "actors":[], "director":[], "genres":["comedy"], "other":[]},
        "dislikes": {"actors":[], "director":[], "genres":[], "other":[]}
    },
    "userMessage": "Ok. give me some options"
    }
```
Should return a model output like this:
```json
{
  "justification": "The user's previous message indicates they are ready to receive movie options.  Their profile shows a strong preference for comedy movies. Therefore, the query will focus on retrieving comedy movies.",
  "transformedQuery": "comedy films",
  "userIntent": "REQUEST"
}
```

### Learning Resources
- [Genkit Prompts](https://firebase.google.com/docs/genkit-go/prompts)
- [Prompt Engineering](https://www.promptingguide.ai/)
- [Genkit Go examples](https://github.com/firebase/genkit/tree/main/go/samples/menu)