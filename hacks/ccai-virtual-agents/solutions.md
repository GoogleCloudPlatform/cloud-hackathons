# CCAI GHACK COACH GUIDE

## Acrynoms
1. Dialogflow = DF
2. Dialogflow CX Console = Console
3. Data Store = DS
4. Virtual Agent = VA


## Challenge 1 
> Goal: Create and initialize a Dialogflow agent
1. Open the [Diaglogflow CX](https://dialogflow.cloud.google.com/cx/projects) Console
2. Create a new Agent (choose "**build your own**") (use defaults for everything)
3. Open the "Test Agent" panel and post a 'hello' message to the new agent (use defaults for everything)

> At this point you have a new agent that can process simple Intents for greetings

4. Download the [sample HTML page](./resources/page.html).
5. In the Console, go to "Manage -> Integrations" and connect "DiaglogFlow Messenger". Accept all defaults and click "Enable the unauthenticated API". 
6. The DialogFlow Messenger will generate HTML code. Copy that code and add it to the page.html that you've downloaded on your local machine. 
7. **TODO**: upload the page.html to the webserver (or is it OK to run locally?). **Note:** If the user is running locally, then they'll have to know how to setup a simple http server, otherwise it's unlikely that this will  work if they just double-click on the page.html and open it in their browser.  
> At this point we have the agent testable in the Console or via the webpage (for end users)

## Challenge 2
> Goal: Set up a basic Q&A steering using Intents and Event handlers 

1. Go to "Manage Agent -> Intents"
2. Create a new Intent called "Escalate to human"
3. Add a 6 training phrases like:
    1. "I want to talk to an agent"
    2. "I want to talk to a person."
    3. "Agent NOW"
    4. "Can I talk to a human"
    5. "connect me to a person"
    6. "Representative now!!!"
4. Open the Start Page of the Agent
5. Open up Routes and Add the new route
    1. Choose the "Escalate to human" intent
    2. Add an Agent Response of "Sending you to an agent now"
    3. Save!!!
6. Open "Test Agent" and test both Intents
> At this point agent can respond to the two intents (hello and escalate)

## Challenge 3
> Goal: Give Agent access to PDF documents to use in chat answers

1. Create a bucket and a folder and upload PDF files into it
1. In the DF Console, agent "Start Page" click "Add State Handler" and select "Data Store"
2. Select to Add Data Store (the "+") the click "Create Vertex AI Search and Conversation app"
3. This opens up [agent builder](www.link.com) where you can create the data store by uploading documents
4. Give the agent a name and hit next
5. Select "Create New Data store" and select the folder in GCS
6. Give the Data Store a name and create it
7. Go back to DF Console and repeat steps 2 and 3. You should now see the option to select your document DS from a dropdown

    > At this point you have created a Data Store that is processing your PDFs, indexing them and making them available for searching and summarization 

    > Indexing can take about 5-10 minutes for the given documents 

9. Test the agent with some questions from the documents, for example:
    1. "How much time off do i get?" 
    2. "what is our vacation policy?" 
    3. "what is our parental leave?"

    You can also ask followup questions as the VA keeps the conversation context

## Challenge 4
> Goal: Update our agent flow to include answers based on generator 

1. From the Start Page, go to the Default Welcome Intent. Under Fulfillment open Generators and select "+ New generator" 
2. Give it a name like "Gen Welcome"
3. Under prompt suggest it greet the users based on the previous message. For example: 

    ```
    A user started a conversation with you, a chat bot, greet them politely and tell them something helpful about your ability to answer questions for a worker at Piped Piper Co. The last thing they said was $last-user-utterance
    ```
4. Give the Output parameter a name, for example `$request.generative.mygreeting`

5. Remove the hardcoded agent responses and replace them with the output parameter name from step #4 above
6. Test the agent with different welcome phrases

## Challenge 5
> Goal: Call external system for knowledge

1. Create a new intent for answering a question about vacation days. Use the steps in Challenge 1 to create it.

2. create a webhook
    1. Go to Manage -> Webhooks -> Create new
    2. Fill in a name and set Subtype -> Flexible, Method -> GET
    3. Webhook URL -> TBD **TODO: create cloud function \ stub for this** 
    4. Fill in request parameters:
        1. $flow.vacation variable to store the result
        2. $.fulfillment_response.messages[0].text.days to store the response from the JSON
    5. Go to Start Page and create a new Route ("+" sign )
    6. Select vacation days Intent
    7. Under Fulfillment select Webhook Settings -> Enable Webhook and select the vacation days webhook
3. **TODO** Use webhook response to the user question

