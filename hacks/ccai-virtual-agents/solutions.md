# CCAI GHACK COACH GUIDE

## Acronyms
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
1. Click the **+** icon to add a Data Store and a new **Data stores** panel will open up on the right.
1. Click in the drop down list for type **Unstructured Documents**
1. Select **+ Create data store** 
1. This will open up a new browser tab with the Agent Builder console:
    1. Click **SELECT** for Cloud Storage
    1. On the next page, select **Unstructured documents** and browse to the `HR-Policies` folder in GCS where you unzipped all the PDFs documents at the beginning of this challenge.
    1. Click **CONTINUE**
    1. Give your data store a name such as `piped-piper-hr-docs` 
    1. Click **CREATE**

> **NOTE**: Your new data store can take 10+ minutes to fully ingest all of the PDF documents. If you click into the data store on the Agent Builder page, you can watch its progress.

1. When your data store is ready, go back to the **Build** panel, select the **Start Page**, click the **+** next to **Data stores** 
1. Click in the drop down list for type **Unstructured Documents**
1. Select the new `piped-piper-hr-docs` data store.
    1. **NOTE:** Until your data store is fully ingested, it will not show up in the drop down box. If you still don't see it, try refreshing the browser.
1. Click **Save** at the top of the panel.
1. Test the agent with some questions from the documents, for example:
    1. "What is our paid time off policy?" 
    1. "What types of termination are there?"
    1. "What is our leave policy?"

You can also ask follow up questions because the Agent keeps the conversation context.


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
> **GOAL**: Call an external system for data we can use in responses

1. Create a new Intent called **Vacation Days Query** for answering questions about vacation days remaining.
    1. **NOTE:** If you have a well worded description for this intent, you can use the "x newly generated AI phrases" to create training phrases for you!
1. Create a Webhook by going to the **Manage** panel, select **Webhooks** and click the **+ Create** button.
1. Name it **Get Vacation Days**
1. Set Subtype to **Flexible**, set Method to **Get**
1. For the webhook URL, enter the URL from the Cloud Function that was pre-created for you named: `vacation-days`
    1. It should look like this: `https://us-central1-my-project-id.cloudfunctions.net/vacation-days`
1. In the **Response configuration** section fill in:
    1. Parameter name: `vacation_days_left`
    1. Field path: `vacation_days_left`
1. In the **Request Headers** section fill in:
    1. Key: `Authorization`
    2. Value: `bearer xxxxxx`
        1. Where `xxxxxx` is the output of this command: `gcloud auth print-identity-token`
1. Finish by clicking **Save** at the top of the Webhook panel
1. Go to the **Build** panel and in the **Start Page** click the **+** button beside **Routes**.
    1. In the **Intent** section, select the **Vacation Days Query** intent that you created earlier.
    1. In the **Fulfillment** section, open the **Webhook settings** section and fill in:
        1. Check the **Enable Webhook** checkbox
        1. Webhook: **Get Vacation Days** 
        1. Tag: { any string you want, it just can't be blank }
    1. In the **Transition** section select **Page**
        1. In the drop down select **+ new Page**
        1. Call the new page: **Vacation Page**
        1. This will create a new page in the **Build** panel's editor.
1. Click on **Vacation Page** on the canvas of the **Build** panel.
    1. Click on **Entry Fulfillment** field to open the **Fulfillment** panel
    1. In the **Agent Responses / Agent Says** section enter the text you want to use to communicate the answer back to the user. eg:
        1. **You have $session.params.vacation_days_left days left**
        1. **NOTE:** The `$session.params.vacation_days_left` string maps to the output of the webhook that ran before we came to this page.
    1. **NOTE**: Just like we did in Challenge 4, we could use a Generator to communicate the number of vacation days and have an LLM create the response.