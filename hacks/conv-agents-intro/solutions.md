# Coach Guide | Introduction to Conversational Agents

## Challenge 1 
> **GOAL**: Create and initialize a Conversational Agent

1. Download the zip file containing all files we'll use in this gHack from [this link](https://github.com/gfilicetti/ces-agents-intro/archive/refs/heads/main.zip).
    1. You can use this command in Cloud Shell to download it:

        ```bash
        wget https://github.com/gfilicetti/ces-agents-intro/archive/refs/heads/main.zip
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

9. When your data store is ready, go back to the Tools screen, select your new **HR Policy Documents** tool and you will see a new section at the bottom.
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

> **NOTE** The terraform scripts that set up this gHack have already deployed a Cloud Run Function. It is this function that we're using to simulate an external service.

1. In the [Conversational Agents Console](https://dialogflow.cloud.google.com/v2/projects/) select **Tools** from the left-hand panel.  Click on the **+ Create** button.
    1. Name the new tool: **Vacation Days Query** for answering questions about how many vacation days an employee has remaining.
    1. Type: **OpenAPI**
    1. Give it a description
    1. In the **Schema** section, select **YAML**. 
    1. Paste in the following YAML into the text box. Make sure to replace the clound function URL with your own:

```yaml
openapi: 3.0.0
info:
  title: Vacation Days API
  version: 1.0.0
servers:
  - url: https://us-central1-ccai-ghacks.cloudfunctions.net # Replace with your root Cloud Run URL
paths:
  /vacation-days: # Matches the function name in your URL
    get:
      summary: Get remaining vacation days
      operationId: getVacationDays
      responses:
        '200':
          description: Number of vacation days remaining
          content:
            application/json:
              schema:
                type: object
                properties:
                  vacation_days_left:
                    type: integer
                    description: The number of vacation days left.
                    example: 15 # Example value, this is never actually returned
```

6. In the **Authentication** section, select **Service Agent Token** and then **ID Token**
1. Now we have to give access to the Google managed service account for Conversational Agents.
    1. It is named: `service-{PROJECT_NUMBER}@gcp-sa-dialogflow.iam.gserviceaccount.com`
    1. You need to give it these two roles:
        - `roles/run.invoker`
        - `roles/cloudfunctions.invoker`
    1. This can be done with the following commands:

        ```bash
        gcloud projects add-iam-policy-binding $(gcloud config get-value project) \
        --member="serviceAccount:service-{PROJECT_NUMBER}@gcp-sa-dialogflow.iam.gserviceaccount.com" \
        --role="roles/run.invoker"
        ```

        ```bash
        gcloud projects add-iam-policy-binding $(gcloud config get-value project) \
        --member="serviceAccount:service-{PROJECT_NUMBER}@gcp-sa-dialogflow.iam.gserviceaccount.com" \
        --role="roles/cloudfunctions.invoker"
        ```

1. Leave the defaults for everything else and click **Save** at the top middle of the screen.

1. Now we have to add this new tool to our Playbook so that it will be used by the agent.
1. Select **Playbooks** from the left hand panel and open the playbook we've been working on.
1. Add a new bullet point in the middle of the list like this:

    ```bash
    - Use ${TOOL:Vacation Days Query} to help answer questions about vacation days
    ```

1. Now you can test if this works in the Agent preview/test window. Ask it something like **How many vacation days do I have left?**
