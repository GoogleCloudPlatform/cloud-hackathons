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
- gCloud CloudShell terminal

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
 - Go back to the terminal in the  **cloud shell editor**.
 - Clone the repo and naviagate to the folder.
```sh
git clone https://github.com/MKand/movie-guru.git --branch test-ghack
cd movie-guru
```
 - Re-open the **Cloud Shell Editor** with the folder movie-guru as the current workspace.

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


