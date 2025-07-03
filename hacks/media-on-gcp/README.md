# Media & Entertainment on Google Cloud

## Introduction

The Media & Entertainment on Google Cloud gHack will take you on a whirlwind tour in the world of media technology and how it is being used in the modern world of cloud based and AI services.

## Learning Objectives

In this hack you will be solving the common business problems that all companies in the Media & Entertainment industry are facing and how Google Cloud and our AI solutions fit in:

1. Provision appliances
1. Set up SRT sources
1. Create advert visuals

## Challenges

- Challenge 0: Veo3 Ad Creative
  - Log into Media Studio 

- Challenge 1: Norsk
  - Load Norsk Studio. (blank canvas)
  - Drag an SRT Ingest component to the canvas, connect to camera source1
  - Repeat for camera source 2, 3 and 4.
  - Create an SRT Egest component set x,y,z (if req'd, TBD).
  - Note down SRT locations, you'll need them in the next step.


- Challenge 2: Connect Streams to Vizrt Vectar
  - Connect to Vizrt using either Teamviewer or HP Anywhere
  - Configure inputs as the SRT sources from Challenge 1
  - Verify you can transition (video mix) between sources, 1,2,3 and 4
  - Configuire an SRT output from Vectar, note down the details, you'll need them in the next challange


- Challenge 3: Techex Darwin
  - Connect to Techex Darwin
  - Connect the SRT ingest point to the output from Vizrt Vectar in the previous step
  - Press the button in Techex Darwin to insert a scte-35 marker into the program out stream
  - Configure the SRT output

- Challenge 4: Ateme Titan Live
  - Connect to Titan Live
  - Configure a new input to receive the stream from techex Darwin


- Challenge 5: Video JS Player
  - Clone Git hub repo for VideoJS Player
  - Publish to Cloud Run

- Challenge 6: View your live channel.

## Prerequisites

- Basic knowledge of GCP
- Access to a GCP environment

## Contributors

- Jorge Sanchez
- Chris Hampartsoumian
- Chanka Perera
- Michael Bychkowski
- Gino Filicetti

## Challenge 1: Norsk setup 

https://norsk.video/
Find the Norsk server on your environment, use the public ipaddress to access the norsk-studio 

Example : https://<publicip_of_norsk_instance>/
Your coach will provide login credentials 

First, we'll add the four input sources. These are all **SRT Ingest (Caller)** , meaning Norsk will "call" a remote source to pull the stream.

We have 12 SRT sources running on following instances. 

IP: 34.147.220.43 port 5121-5126
IP: 35.246.1.71 port 5121-5126

So distribute the load between these servers 


1.  In the **Component Library** on the left, find the **Inputs** section.
2.  Click and drag the **SRT Ingest (Caller)** component onto the main canvas. Repeat this three more times, so you have four input nodes in total.
3.  Click on each node to open its configuration panel and enter the details as follows, 
    * **Input 1:**
        * `displayName`: camera1
        * `host`: 34.147.220.43 
        * `port`: 5121
        * `streamId`: camera1
    * **Input 2:**
        * `displayName`: camera2
        * `host`: 34.147.220.43 
        * `port`: 5122
        * `streamId`: camera2
    * **Input 3:**
        * `displayName`: camera3
        * `host`: 35.246.1.71 
        * `port`: 5123
        * `streamId`: camera3
    * **Input 4:**
        * `displayName`: camera6
        * `host`: 35.246.1.71
        * `port`: 5126
        * `streamId`: camera4

## Step 2: Add Your Output Destinations 

Next, you'll add the four output destinations. The configuration specifies these should be **SRT Listener (Egest)** nodes. This means Norsk will "listen" for a remote player or device to connect and receive the stream.

1.  In the **Component Library**, find the **Outputs** section.
2.  Click and drag the **SRT Listener (Egest)** component onto the canvas. Repeat this three more times. It's good practice to place them to the right of your input nodes.
3.  Configure each listener with its unique port:
    * **Output 1:**
        * `displayName`: srt-listener-camera1
        * `port`: 5111
    * **Output 2:**
        * `displayName`: srt-listener-camera2
        * `port`: 5112
    * **Output 3:**
        * `displayName`: srt-listener-camera3
        * `port`: 5113
    * **Output 4:**
        * `displayName`: srt-listener-camera6
        * `port`: 5116

## Step 3: Connect the Nodes

The final step is to connect your inputs to your outputs. This tells Norsk where to send the media from each source. Your goal is to create four parallel, independent streams.

1.  Hover your mouse over the **camera1** node until a small circle appears on its right side. This is the **output handle**.
2.  Click and drag from the output handle of the **camera1** node to the input handle (the circle on the left) of the **srt-listener-camera1** node. A line will appear, showing the connection.
3.  Repeat this process for the remaining pairs, Now you can save your config as a YAML file for future use. 
    * Connect **camera2** to **srt-listener-camera2**.
    * Connect **camera3** to **srt-listener-camera3**.
    * Connect **camera4** to **srt-listener-camera4**.
**

## Challenge 2: Connect Streams to Vizrt Vectar
Product Guide - https://www.vizrt.com/vizrt/remote/viz-vectar-plus/

### Notes & Guidance

In this challenge, participants will work with a professional video mixing tool, Vizrt Vectar. The main tasks are configuring inputs from the previous step and creating a new output stream.

Your coach will help you setting up license to to setup the hp-anywhere_pcoip-client so you would be able to connect to the Vizrt instance. 

1.  **Connect to Vizrt Using HP Anywhere:** Get the Windows username and password from the coach
2.  **Configure Inputs:**
    * Within the Vectar interface Press the Setup button at the top of the screen
    * Configure Input 1 but locating input 1 in the setup screen and clicking the 'Configure' wheel at the end of the row.
    * In the dialoug box that opens, from the source drop down menu chooses Local -> Add IP Source....
    * In the Soure Manager Dialog that opens, click the configure wheel next to camera1
    * In the Configure SRT Input Connection dialog box that opens, enter Camera1 in the Connection Name field
    * In order to know the server URL, check the internal IP address of the ibc-ghack-norsk-gw-vm in Compute Engine. In this example, it is 10.164.0.5, yours may be different.
    * In the Server URL enter srt://10.164.0.5
    * In the port Number enter 5111 which was the port number allocated to camera1 in Norsk.
    * Press Okay. (You will see a message about resetting your session, but we will add the other cameras first)
    * Repeat the process for Camera 2, Camera 3 and Camera 4
    * Now we need reset vizrt to receive the steams.
    * Go to File -> Exit (you may need to position your mouse at the top of the screen to get the File Menu to appear.
    * Press Exit - when asked are you sure you want to exit.
    * This takes you to Kiosk mode, now click start Live Production in the bottom Right Corner.
    * Viz takes a while to come back, when it's back you still need to configure the inputs.
    * For Input1 Thumbnail, click the configure wheel in the bottom right of the thumbnail
    * In the Input1 Dialog box, select Source -> Local -> Camera1
4.  **Verify Transitions:**
    * After configuring the inputs, the four camera sources should appear in Vectar's source preview monitors.
    * Guide them to use the Vectar's switcher controls (e.g., clicking on sources to put them in 'Preview' and using a T-bar or 'Cut'/'Auto' buttons to transition them to 'Program'). This confirms that the streams are correctly ingested and that Vectar is operational.
5.  **Configure SRT Output:**
    * Similar to Norsk, they now need to configure an output stream. This is typically done in the 'Output' or 'Streaming' settings.
    * To Configure the output Locate the button that says 'STREAM' in the top menu, press the configure wheel next to that button
    * Locate the output labelled SRT Stream that has a tick mark next to it, click the Configure wheel to the right
    * In the Configure SRT Connection Dialog box, choose Connection Type drop down -> Host Local SRT Stream
    * Leave the Server Port at 10000
    * Note the Access URL, this will  be used downstream
    * Press Close, twice.
    * Now press the Stream button at the top of the screen. 
    * They must set the output type to **SRT**. Vectar will provide a new SRT URL for its program output.
    * **Participants must note down this new SRT output URL** for the next challenge.


## Challenge 3: Techex Darwin
https://www.techex.tv/technologies/txdarwin


### Notes & Guidance

1.  **Connect to Techex Darwin:** Participants will connect to the Darwin UI via its web interface.
2.  **Configure SRT Ingest:**
    * Create a new input and configure it to be an **SRT source**.
    * Paste the SRT output URL from Vizrt Vectar (Challenge 2) into the ingest configuration. The program feed from Vectar should now be flowing into Darwin.
3.  **Insert SCTE-35 Marker:**
    * The Darwin interface has a feature for live stream manipulation. Guide participants to find the button or control labeled **"Insert SCTE-35 Marker"** or similar.
    * Pressing this button injects the ad signaling marker into the transport stream in real-time. This doesn't change the video content itself but adds metadata that downstream systems will use.
4.  **Configure SRT Output:**
    * Create a new SRT output for the stream that now contains the SCTE-35 marker.
    * **Ensure participants copy the SRT output URL from Darwin**, as it will be the input for Ateme Titan Live.

***


## Challenge 4: Ateme Titan Live
https://www.ateme.com/product-titan-software/

### Notes & Guidance

Ateme Titan Live is a broadcast-grade encoder. In this step, participants will configure it to receive the final produced stream and prepare it for delivery over the web. As shown in the architecture diagram, Titan Live is the final step before the stream is handed off to Google Cloud's media services.

1.  **Connect to Titan Live:** Participants should log in to the Titan Live web interface.
2.  **Configure New Input:**
    * They need to create a new input channel.
    * Set the input source type to **SRT**.
    * In the configuration, they will paste the **SRT output URL from Techex Darwin** (from Challenge 3).
3.  **Configure Output/Profile:**
    * The primary goal is to have Titan Live process the stream. A default encoding profile (e.g., H.264/AAC in an HLS format) should be sufficient.
    * The crucial part of the configuration is setting up the destination. In our architecture, Titan Live will hand off to the **Ateme Nea Packager**, which then interfaces with the **Google Cloud Video Stitcher API**. This may be a pre-configured output profile in Titan Live that participants just need to select. The output should be configured to create HLS manifests.

## Challenge 5: VideoJS Player

### Notes & Guidance

This challenge moves from broadcast-specific tooling to a standard cloud workflow: deploying a web application using a containerized service.

1.  **Clone Git Repository:**
    * Participants need to use a terminal with `gcloud` and `git` installed.
    * They should clone the provided repository for the VideoJS Player.

    ```shell
    git clone [https://github.com/google-cloud-vietnam/ghack-videojs-player.git](https://github.com/google-cloud-vietnam/ghack-videojs-player.git)
    cd ghack-videojs-player
    ```
2.  **Publish to Cloud Run:**
    * The easiest way to deploy is using the `gcloud run deploy` command from the root of the cloned repository. This command will build the container image from the source and deploy it.
    * Participants can name their service whatever they like (e.g., `ghack-player`).
    * The `--allow-unauthenticated` flag is important to make the player publicly accessible for testing.

    ```shell
    gcloud run deploy ghack-player --source . --region europe-west1 --allow-unauthenticated
    ```

    > **Note**: After the deployment succeeds, the command line will output the service URL. **This is the URL for the live channel player.**

***

## Challenge 6: View Your Live Channel

### Notes & Guidance

This is the final step where everything comes together. Participants will see their live stream, complete with an advertisement inserted via the Google Cloud Video Stitcher API, triggered by the SCTE-35 marker they inserted earlier.

1.  **Open the Player:**
    * Participants should navigate to the **Cloud Run service URL** they obtained in the previous challenge.
2.  **Verify the Stream:**
    * The VideoJS player should load and start playing the live video feed originating from the Norsk sources, mixed in Vectar, and processed by Darwin and Titan.
3.  **Look for the Ad:**
    * The key to success for this entire hack is seeing an advertisement. The SCTE-35 marker inserted in Challenge 3 signals the Google Cloud Video Stitcher API (via the Ateme components) to insert an ad from Google Ad Manager.
    * When the ad plays, it confirms the entire workflow is functioning correctly. If no ad appears, common issues to troubleshoot are:
        * The SCTE-35 marker was not inserted correctly in Darwin.
        * The integration between Titan Live and the Video Stitcher API is misconfigured.
        * There is an issue with the Google Ad Manager campaign.


***



***This is a template for a single challenge. The italicized text provides hints & examples of what should or should NOT go in each section. You should remove all italicized & sample text and replace with your content.***

> **Note**
> *Use this format for sample informational blockquote, the Note part is case sensitive*

> **Warning**
> *Use this format for sample warning blockquote, the Warning part is case sensitive*

### Pre-requisites (Optional)

*Include any technical pre-requisites needed for this challenge specifically.  Typically, it is completion of one or more of the previous challenges if there is a dependency. This section is optional and may be omitted.*

### Introduction (Optional)

*This section should provide an overview of the technologies or tasks that will be needed to complete the this challenge.  This includes the technical context for the challenge, as well as any new "lessons" the attendees should learn before completing the challenge.*

- *Optionally, the coach or event host is encouraged to present a mini-lesson (with the provided lectures presentation or maybe a video) to set up the context and introduction to each challenge. A summary of the content of that mini-lesson is a good candidate for this Introduction section*

*For example:*

When setting up an IoT device, it is important to understand how 'thingamajigs' work. Thingamajigs are a key part of every IoT device and ensure they are able to communicate properly with edge servers. Thingamajigs require IP addresses to be assigned to them by a server and thus must have unique MAC addresses. In this challenge, you will get hands on with a thingamajig and learn how one is configured.

### Description

*This section should clearly state the goals of the challenge and any high-level instructions you want the students to follow. You may provide a list of specifications required to meet the goals. If this is more than 2-3 paragraphs, it is likely you are not doing it right.*

> **Note** *Do NOT use ordered lists as that is an indicator of 'step-by-step' instructions. Instead, use bullet lists to list out goals and/or specifications.*

> **Note** *You may use Markdown sub-headers to organize key sections of your challenge description.*

*Optionally, you may provide resource files such as a sample application, code snippets, or templates as learning aids for the students. These files are stored in the hack's `resources` sub-folder. It is the coach's responsibility to package these resources and provide them to students in the Google Space's Files section as per [the instructions provided](https://ghacks.dev/faq/howto-host-hack.html#making-resources-available).*

> **Note** *Do NOT provide direct links to files or folders in the gHacks Github repository from the student guide. Instead, you should refer to the "resources in the Google Space Files section".*

*Here is some sample challenge text for the IoT Hack Of The Century:*

In this challenge, you will properly configure the thingamajig for your IoT device so that it can communicate with the mother ship.

You can find a sample `thingamajig.config` file in the Files section of this hack's Google Space provided by your coach. This is a good starting reference, but you will need to discover how to set exact settings.

Please configure the thingamajig with the following specifications:

- Use dynamic IP addresses
- Only trust the following whitelisted servers: "mothership", "IoTQueenBee"
- Deny access to "IoTProxyShip"

### Success Criteria

- *Success criteria go here. The success criteria should be a list of checks so a student knows they have completed the challenge successfully. These should be things that can be demonstrated to a coach.*
- *The success criteria should not be a list of instructions.*
- *Success criteria should always start with language like: "Validate XXX..." or "Verify YYY..." or "Show ZZZ..." or "Demonstrate VVV..."*

*Sample success criteria for the IoT sample challenge:*

- Verify that the IoT device boots properly after its thingamajig is configured.
- Verify that the thingamajig can connect to the mothership.
- Demonstrate that the thingamajig will not connect to the IoTProxyShip

### Tips

*This section is optional and may be omitted.*

*Add tips and hints here to give students food for thought. Sample IoT tips:*

- IoTDevices can fail from a broken heart if they are not together with their thingamajig. Your device will display a broken heart emoji on its screen if this happens.
- An IoTDevice can have one or more thingamajigs attached which allow them to connect to multiple networks.

### Learning Resources

*This is a list of relevant links and online articles that should give the attendees the knowledge needed to complete the challenge.*

*Think of this list as giving the students a head start on some easy Internet searches. However, try not to include documentation links that are the literal step-by-step answer of the challenge's scenario.*

> **Note** *Use descriptive text for each link instead of just URLs.*

*Sample IoT resource links:*

- [What is a Thingamajig?](https://www.google.com/search?q=what+is+a+thingamajig)
- [10 Tips for Never Forgetting Your Thingamajig](https://www.youtube.com/watch?v=dQw4w9WgXcQ)
- [IoT & Thingamajigs: Together Forever](https://www.youtube.com/watch?v=yPYZpwSpKmA)

### Advanced Challenges (Optional)

*If you want, you may provide additional goals to this challenge for folks who are eager.*

*This section is optional and may be omitted.*

*Sample IoT advanced challenges:*

Too comfortable?  Eager to do more?  Try these additional challenges!

- Observe what happens if your IoTDevice is separated from its thingamajig.
- Configure your IoTDevice to connect to BOTH the mothership and IoTQueenBee at the same time.

### Environment Setup

The deployment of this gHacks considered two environments:

1) **Target environment**: Target environment is the ephemeral student project where all infrastructure will be created for the hack.
2) **Source environment**: Source environment is a prerequisite environme for the Target environment for pulling licenses and custom images to run in Target project.

#### File and variable setup

Define environment variables to run Terraform.
```
export GCP_PROJECT_ID_SOURCE=<you-source-project-id>

export GCP_PROJECT_ID=<you-project-id>
export GCP_REGION=europe-west4
export GCP_ZONE=europe-west4-b
```

Setup necessaey org policies to run the Terraform script.
```sh
. ./scripts/process_policies.sh
```

And enter in the required params to run scripts when prompted.

#### Setup for Source environment

When setting up source environment, make sure the logged in user has administrator level access to the environment.

```
gcloud auth login
gcloud auth application-default login
gcloud config set project ${GCP_PROJECT_ID_SOURCE}
```

Apply necessary policies for

```sh
gcloud org-policies set-policy ./artifacts/scripts/processed_policies/iam.allowedPolicyMemberDomains.yaml
```

#### Setup for Target environment

When setting up target environment, make sure the logged in user has administrator level access to the environment.

```
gcloud auth login
gcloud auth application-default login
gcloud config set project ${GCP_PROJECT_ID_SOURCE}
```

Set necessary policies. Make sure the proper org administrator and project

Apply necessary policies if needed.

```sh
gcloud org-policies set-policy ./artifacts/scripts/processed_policies/compute.storageResourceUseRestrictions.yaml
gcloud org-policies set-policy ./artifacts/scripts/processed_policies/compute.trustedImageProjects.yaml
gcloud org-policies set-policy ./artifacts/scripts/processed_policies/compute.vmExternalIpAccess.yaml
```

Run Terraform `init`, `plan`, and `apply`.
```tf
terraform init

terraform plan \
  -out=out.tfplan \
  -var "gcp_project_id=${GCP_PROJECT_ID}" \
  -var "gcp_region=${GCP_REGION}" \
  -var "gcp_zone=${GCP_ZONE}"

terraform apply "out.tfplan" \
  -auto-approve
```
