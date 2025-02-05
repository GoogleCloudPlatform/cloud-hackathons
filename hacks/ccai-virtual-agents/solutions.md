# Coach Guide | Intro to CCAI and Virtual Agents

## Challenge 1 
> **GOAL**: Create and initialize a Dialogflow agent

1. Download the zip file containing all files we'll use in this gHack from [this link](https://github.com/gfilicetti/ccai-virtual-agents/archive/refs/heads/main.zip).
    1. You can use this command in Cloud Shell to download it:

        ```bash
        wget https://github.com/gfilicetti/ccai-virtual-agents/archive/refs/heads/main.zip
        ```

1. Open the [Conversational Agents Console](https://dialogflow.cloud.google.com/v2/projects/) and select your project.
1. Create a new Agent 
    1. Choose **Build your own**
    1. Give it a name and then use defaults for everything
    1. Open the **Toggle Simulator** by clicking the chat icon at the top right of the page
    1. Type a 'Hello' message to the new agent and note its generic reply

> **NOTE**: At this point you have a new agent that can process simple Intents for greetings

1. On the left-hand panel, select **Integrations** near the bottom.
1. Find the square for **Conversational Messenger** and click **Connect**. Keep all of the defaults and click the **Enable the unauthenticated API** button.
1. The Conversational Messenger will generate HTML code. Copy that code and find the file: `agent-page.html` that was in the zip file you downloaded. Paste the code at the bottom of the `<head>` section of the HTML file.
1. We will use a simple python http server to serve up the `agent-page.html` file. 
    1. Go to the Cloud Shell, click the 3 dots near the top right and select **Upload** to upload `agent-page.html` to the root of your home directory
    1. Run a webserver with this command: `python3 -m http.server 8080` 
    1. Click on the **Web Preview** icon (next to the pencil icon) and select **Preview on Port 8080**. This will open a new browser window and show a list of all the files in your home directory. Find and click on `agent-page.html`.
    1. You can now chat with the agent just as you did in the Console. Click on the agent chat icon at the bottom right of the page. Post a 'Hello' message again to see how it answers.

> **NOTE:** At this point we have the agent testable in the Console and via the webpage for end users


## Challenge 2
> **GOAL**: Set up a basic Playbook to detect an escalation scenario

1. Back in the Console select **Playbooks** in the left-hand panel.
1. Pick the **Default Generative Playbook**
1. Add a Goal to Playbook such as:
    1. *You are a chat agent whose job is to help employees with their queries*
1. Add a series of **Instructions** as well, such as:
    - *Greet the users, then ask how you can help them today*
    - *Summarize the user's request and ask them to confirm that you understood correctly.*
    - *If necessary, seek clarifying details.*
    - *If the user asks to speak with an agent or is frustrated, escalate to a human agent.*
    - *Thank the user for their business and say goodbye.*
1. Click **Save** at the top middle of the page
1. Click on the **Examples** at the top left of the page
    1. We need to train the agent to recognize an escalation scenario.
1. Click the **+ Example** button to create a new example
    1. Give your example a name such as **Escalate**.
    1. At the very bottom of the right-hand panel, start typing example phrases that a user might type to ask for a human agent.
        1. *Hello*
        1. *Doing well*
        1. *I want to speak to an agent*
    1. Click the save button (a disk icon) at the top right of the screen and fill in the fields that appear at the bottom: 
        1. Give your example a summary: *Escalating to a call center agent*
        1. Change the Conversation State to **ESCALATED**
1. Go back to the Simulator (or your web app) and have a conversation that should result in an escalation. If it is not working, you should add more examples.


## Challenge 3
> **GOAL**: Give the Agent access to PDF documents to use in chat answers

1. Create a Google Cloud Storage bucket and a folder and upload the PDF files from the zip file you downloaded.
    1. You can run these commands in the Cloud Shell if you unzipped your files there:
        ```bash
        gsutil mb gs://$(gcloud config get project)-documents
        gsutil cp ./piped-piper/documents/*.pdf gs://$(gcloud config get project)-documents/HR-Policies 
        ```
1. In the [Conversational Agents Console](https://dialogflow.cloud.google.com/v2/projects/) select **Playbooks** from the left-hand panel. Select the Default Playbook and at the bottom, click on the **+ Datastore** button.
1. This will bring you to the **Tools** page. 
    1. Name the tool **HR Policy Documents** 
    1. Leave the Type as **Data store** 
    1. Add a description such as *Repository of HR policy documents*. 
    1. Click the **Save** button at the top middle of the page
1. Select the **Create a data store** link at the bottom of the page.
1. This will open up a new browser tab with the Agent Builder console:
    1. You should be in the **Apps** section on the left-hand panel. Type in *Piped Piper* for a company name in the **Agent Configurations** text box and click **CONTINUE**
    1. On the Data Stores step click the **CREATE DATA STORE** button at the top middle of the screen.
    1. On the next page, find the **Cloud Storage** box and click **SELECT**.
    1. On the next page, select **Unstructured documents** and browse to the `HR-Policies` folder in GCS where you unzipped all the PDFs documents at the beginning of this challenge.
    1. Click the **CONTINUE** button
    1. Give your data store a name such as `piped-piper-hr-docs` 
    1. Click the **CREATE** button
    1. Now it brings you back to the table of Data Stores. Make sure your new data store is selected and click the **CREATE** button.

> **NOTE**: Your new data store can take 10+ minutes to fully ingest all of the PDF documents. If you click into the data store on the Agent Builder page and click on the Activity tab you can watch its progress.

1. When your data store is ready, go back to the Tools screen, select your new **HR Policy Documents** tool and you will see a new section at the bottom.
1. In the drop down on the left of **Unstructured documents** select your new data store.
1. Leave all other defaults and click **Save** at the top middle of the screen.
1. Go back to your Default Playbook 
    1. At the bottom of the screen, check the box beside our new data store Tool **HR Policy Documents** 
    1. In the prompt add a new instruction to point the agent to our policy documents for more answers. Add this text to the prompt:
        - Use the placeholder `${TOOL:HR Policy Documents}` to help answer questions about HR policy
    1. Click **Save** at the top middle of the screen
1. Go to the Simulator and test the agent with some questions that can be answered from the documents, for example:
    1. *What is our paid time off policy?*
    1. *Do we offer sabbaticals?*
    1. *What is our paid leave policy?*

> **NOTE:** Make sure the students know you can ask follow up questions because the Agent keeps the conversation context.


## Challenge 4
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