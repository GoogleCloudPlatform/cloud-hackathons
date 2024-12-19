# CCAI GHACK COACH GUIDE

## Acrynoms
1. Dialogflow = DF
2. Dialogflow CX Console = Console
3. Data Store = DS
4. Virtual Agent = VA

## Challenge 1 
> **GOAL**: Create and initialize a Dialogflow agent

1. Download the zip file containing all files we'll use in this gHack from [this link](https://github.com/gfilicetti/ccai-virtual-agents/archive/refs/heads/main.zip).
    1. You can use this command in Cloud Shell to download it:

        ```bash
        wget https://github.com/gfilicetti/ccai-virtual-agents/archive/refs/heads/main.zip
        ```

1. Open the [Diaglogflow CX](https://dialogflow.cloud.google.com/cx/projects) Console and select your project.
1. Create a new Agent (choose "**Build your own**") 
    1. Give it a name and then use defaults for everything
    1. Open the "Test Agent" panel and select **Test agent in environment** 
    1. Post a 'Hello' message to the new agent and note its generic reply

> **NOTE**: At this point you have a new agent that can process simple Intents for greetings

1. In the Console, go to **Manage** on the panel at the left side of the screen.
1. On the Manage panel select **Integrations** near the bottom.
1. Click on **DiaglogFlow Messenger**. Keep all of the defaults and click the **Enable the unauthenticated API** button. 
1. The DialogFlow Messenger will generate HTML code. Copy that code and find the file: `agent-page.html` that was in the zip file you downloaded. Paste the code into the `<head>` section of the HTML file.
1. We will use a simple python http server to serve up the `agent-page.html` file. 
    1. Go to the Cloud Shell, click the 3 dots near the top right and select **Upload** to upload `agent-page.html` to the root of your home directory
    1. Run a webserver with this command: `python3 -m http.server 8080` 
    1. Click on the **Web Preview** icon (next to the pencil icon) and select **Preview on Port 8080**. This will open a new browser window and show a list of all the files in your home directory. Find and click on `agent-page.html`.
    1. You can now chat with the agent just as you did in the Console. Click on the agent chat icon at the bottom right of the page. Post a 'Hello' message again to see how it answers.

> **NOTE:** At this point we have the agent testable in the Console and via the webpage for end users


## Challenge 2
> **GOAL**: Set up a basic Q&A steering using Intents and Routes

1. Back in the Console go to the **Manage** panel and select Intents at the top"
1. Create a new Intent named **Escalate to Human**
1. Add 6 training phrases such as:
    1. *I want to talk to an agent*
    1. *I want to talk to a person.*
    1. *Agent NOW*
    1. *Can I talk to a human*
    1. *Connect me to a person*
    1. *Representative now!!!*
1. Click **Save**
1. Go to the **Build** panel at the left of the screen and click on the **Start Page**
1. Click on **Routes** to open the Routes panel and add the new route
    1. Choose the **Escalate to Human** intent
    1. Add a few agent dialogue entries such as:
        1. *Sending you to an agent now*
        1. *Please wait for an agent to assist you*
        1. *Let me get someone for you*
    1. **Save** at the top
1. Open the **Test Agent** panel and test your new intent and routes.

> **NOTE**: At this point agent can respond to the two intents: **Default Welcome Intent** and **Escalate to Human**.


## Challenge 3
> **GOAL**: Give the Agent access to PDF documents to use in chat answers

1. Create a Google Cloud Storage bucket and a folder and upload the PDF files from the zip file you downloaded.
    1. You can run these commands in the Cloud Shell if you unzipped your files there:
        ```bash
        gsutil mb gs://$(gcloud config get project)-documents
        gsutil cp ./piped-piper/documents/*.pdf gs://$(gcloud config get project)-documents/HR-Policies 
        ```
1. In the DialogFlow Console go to the **Build** panel on the left and click on **Start Page**. Then click **Add State Handler** and select **Data Store** and then click **Apply**
1. Click the `+` icon to add a Data Store then click **Create Vertex AI Search and Conversation app**
1. This opens up the [Vertex AI Agent Builder](https://console.cloud.google.com/gen-app-builder/engines/create) where you can create the data store by pointing to your GCS bucket
1. Enter our company name: "Piped Piper"
1. Your agent name will be pre-populated with the value you gave earlier. Click Continue.
1. Click **Create New Data Store** and select **Cloud Storage**. Click on **Browse** and find the folder in GCS where the PDFs were uploaded. Click Continue.
1. Give the Data Store a name and click **Create**

> **NOTE**: At this point you have created a Data Store that is processing your PDFs, indexing them and making them available for searching and summarization 

> **NOTE:** Indexing can take about 5-10 minutes for the given documents  

---
---
**START HERE, NEED TO FIGURE OUT WHY PDF DOCS AREN'T WORKING**
---
---

10. Test the agent with some questions from the documents, for example:
    1. "What is our vacation policy?" 
    1. "What types of termination are there?"
    1. "What is our leave policy?"

You can also ask follow up questions as the Agent keeps the conversation context.


## Challenge 4
> **GOAL**: Update our dialogue flow to include answers based on a generator 

1. On the canvas, click on the **Start Page** and click on **Default Welcome Intent**. 
1. In the Fulfillment section, open the Generators section and click **Add generator**
1. Give it a name such as **Generator - Welcome**
1. In the Text Prompt field, suggest that it greet the users based on the previous message. For example: 

    ```
    A user started a conversation with you, a chat bot, greet them politely and tell them something helpful about your ability to answer questions for a worker at Piped Piper. The last thing they said was $last-user-utterance
    ```

1. Give the Output parameter a name, for example `$request.generative.welcomegreeting`
1. In the **Agent responses** section underneath Generators, remove the hardcoded agent responses and replace them with only 1 response using the `$request.generative.welcomegreeting` parameter name we created above
1. Click the **Save** button at the top middle of the panel.
1. Test the agent with different welcome phrases and make sure you get a response conforming to the prompt we're using for this Intent


## Challenge 5
**GOAL**: Call an external system for data we can use in responses

1. Create a new intent for answering a question about vacation days. Use the steps in Challenge 1 to create it.
2. Create a Webhook
    1. Go to Manage -> Webhooks -> Create new
    1. Name it "Get Vacation Days"
    2. Set Subtype -> Flexible, Method -> GET
    3. Webhook URL -> TBD **TODO: create cloud function \ stub for this** 
    4. Fill in request parameters:
        1. $flow.vacation variable to store the result
        2. $.fulfillment_response.messages[0].text.days to store the response from the JSON
    5. Go to Start Page and create a new Route ("+" sign )
    6. Select vacation days Intent
    7. Under Fulfillment select Webhook Settings -> Enable Webhook and select the vacation days webhook
3. **TODO** Use webhook response to the user question

