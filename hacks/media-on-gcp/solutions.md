# Media & Entertainment on Google Cloud: Coach Guide

## Introduction

Welcome to the coach's guide for the *Media & Entertainment on Google Cloud* gHack. This guide provides solutions and notes to help you assist participants through the challenges. The goal is for them to build a live streaming pipeline, from source ingest to playback, incorporating professional broadcast tools and Google Cloud services.

> **Note** If you are a gHacks participant, this is the answer guide to be used by the coaches to help to get students in the right track by providing support and hints. This shouldn't be provided as a setup runbook or step by step guide. The guides are based on ISV/partner products to be deployed in GCP. This ghack assume candidate to have media / broadcasting and creative experience. 

## PRE-GAME: Install license file for 2 x Norsk Studio instances

As a coach, you will need to run these steps manually to copy in the proper license file into the 2 Norsk VMs. 

**NOTE:** Do this as soon as your environment is ready and before the gHack starts

1. Log in as any student and go to the [Cloud Shell](https://shell.cloud.google.com)
1. Copy the license file locally:
    ```shell
    gsutil cp gs://ghacks-media-on-gcp-private/license.json .
    ```
1. Get the names of the Norsk VMs, they are named as you see here but with a unique string instead of `nnn`
    ```shell
    gcloud compute scp ./license.json norsk-gw-nnn:~
    gcloud compute scp ./license.json norsk-ai-nnn:~
    ```
1. SSH to the Norsk GW VM and copy the license file to the right spot and restart the service
    ```shell
    gcloud compute ssh norsk-gw-nnn
    ```
    - Then in the VMs terminal, run:
    ```shell
    sudo mv ~/license.json /var/norsk-studio/norsk-studio-docker/secrets/license.json
    sudo systemctl restart norsk.service
    exit
    ```
1. SSH to the Norsk AI VM and copy the license file to the right spot and restart the service
    ```shell
    gcloud compute ssh norsk-ai-nnn
    ```
    - Then in the VMs terminal, run:
    ```shell
    sudo mv ~/license.json /var/norsk-studio/norsk-studio-docker/secrets/license.json
    sudo systemctl restart norsk.service
    exit
    ```

## Challenge 1: Get creative with the help of AI

### Notes & Guidance

Coach guide for the GenMedia creative challenge goes here

***

## Challenge 2: Gather up those feeds and spit 'em out

Product Information https://norsk.video/

### Notes & Guidance

This initial challenge is designed to be a straightforward introduction to the Norsk Studio interface. Participants will build a simple media flow graph.

1.  **Load Norsk Studio:** Participants should open the Norsk Studio URL provided to them, which will present a blank canvas.
2.  **Add SRT Ingests:**
    - In the components panel, find the **SRT Ingest** component.
    - Participants need to drag four instances of this component onto the canvas.
    - For each SRT Ingest node, they will need to configure it to connect to one of the four camera sources. The configuration panel for the node will require the **IP address and port** for each source stream.
3.  **Create an SRT Egress:**
    - Next, find the **SRT Egress** component and drag it onto the canvas.
    - While the challenge mentions setting x,y,z, the primary goal is to create a combined output. For simplicity, you can have them connect just one of the ingest sources to the egress for now. A more advanced setup might involve a compositor, but that's not required for this step.
4.  **Note SRT Egress Location:**
    - Once the SRT Egress component is configured, Norsk will provide an SRT URL (e.g., `srt://<norsk-ip>:<port>`).
    - **Crucially, participants must copy this URL.** They will need it for the next challenge to configure the input in Vizrt Vectar.

### Step 1: Add Your Input Sources

First, we'll add the four input sources. According to your YAML file, these are all **SRT Ingest (Caller)** nodes, meaning Norsk will "call" a remote source to pull the stream.

We have two input sources 
34.147.220.43:5121-5126
35.246.1.71:5121-5126

So distribute the load between these servers 


1.  In the **Component Library** on the left, find the **Inputs** section.
2.  Click and drag the **SRT Ingest (Caller)** component onto the main canvas. Repeat this three more times, so you have four input nodes in total.
3.  Click on each node to open its configuration panel and enter the details from your YAML file.
    - **Input 1:**
        - `displayName`: camera1
        - `host`: 34.32.228.47 
        - `port`: 5111
        - `streamId`: camera1
    - **Input 2:**
        - `displayName`: camera2
        - `host`: 34.32.228.47 
        - `port`: 5112
        - `streamId`: camera2
    - **Input 3:**
        - `displayName`: camera3
        - `host`: 34.32.228.47 
        - `port`: 5113
        - `streamId`: camera3
    - **Input 4:**
        - `displayName`: camera4
        - `host`: 34.32.228.47 
        - `port`: 5114
        - `streamId`: camera4

### Step 2: Add Your Output Destinations 

Next, you'll add the four output destinations. The configuration specifies these should be **SRT Listener (Egest)** nodes. This means Norsk will "listen" for a remote player or device to connect and receive the stream.

1.  In the **Component Library**, find the **Outputs** section.
2.  Click and drag the **SRT Listener (Egest)** component onto the canvas. Repeat this three more times. It's good practice to place them to the right of your input nodes.
3.  Configure each listener with its unique port:
    - **Output 1:**
        - `displayName`: srt-listener-camera1
        - `port`: 5101
    - **Output 2:**
        - `displayName`: srt-listener-camera2
        - `port`: 5102
    - **Output 3:**
        - `displayName`: srt-listener-camera3
        - `port`: 5103
    - **Output 4:**
        - `displayName`: srt-listener-camera4
        - `port`: 5104

### Step 3: Connect the Nodes

The final step is to connect your inputs to your outputs. This tells Norsk where to send the media from each source. Your goal is to create four parallel, independent streams.

1.  Hover your mouse over the **camera1** node until a small circle appears on its right side. This is the **output handle**.
2.  Click and drag from the output handle of the **camera1** node to the input handle (the circle on the left) of the **srt-listener-camera1** node. A line will appear, showing the connection.
3.  Repeat this process for the remaining pairs, following the logic in your YAML's subscriptions:
    - Connect **camera2** to **srt-listener-camera2**.
    - Connect **camera3** to **srt-listener-camera3**.
    - Connect **camera4** to **srt-listener-camera4**.

***

## Challenge 3: Get in the Mix

Product Guide - https://www.vizrt.com/vizrt/remote/viz-vectar-plus/

### Notes & Guidance

In this challenge, participants will work with a professional video mixing tool, Vizrt Vectar. The main tasks are configuring inputs from the previous step and creating a new output stream.

1.  **Connect to Vizrt:** Participants will need to use the provided credentials for Teamviewer or HP Anywhere to access the remote machine running Vizrt Vectar.
2.  **Configure Inputs:**
    - Within the Vectar interface, they need to navigate to the input configuration section.
    - They should add **four new SRT inputs**.
    - For each input, they will use the SRT source URLs from the Norsk SRT Ingest components they configured in Challenge 1.
3.  **Verify Transitions:**
    - After configuring the inputs, the four camera sources should appear in Vectar's source preview monitors.
    - Guide them to use the Vectar's switcher controls (e.g., clicking on sources to put them in 'Preview' and using a T-bar or 'Cut'/'Auto' buttons to transition them to 'Program'). This confirms that the streams are correctly ingested and that Vectar is operational.
4.  **Configure SRT Output:**
    - Similar to Norsk, they now need to configure an output stream. This is typically done in the 'Output' or 'Streaming' settings.
    - They must set the output type to **SRT**. Vectar will provide a new SRT URL for its program output.
    - **Participants must note down this new SRT output URL** for the next challenge.

***

## Challenge 4: Ready for some Ads?

https://www.techex.tv/technologies/txdarwin

### Notes & Guidance

This challenge introduces SCTE-35 markers, which are fundamental for digital program insertion (like advertising). Techex Darwin is a specialized tool for manipulating transport streams.

1.  **Connect to Techex Darwin:** Participants will connect to the Darwin UI via its web interface.
2.  **Configure SRT Ingest:**
    - Create a new input and configure it to be an **SRT source**.
    - Paste the SRT output URL from Vizrt Vectar (Challenge 2) into the ingest configuration. The program feed from Vectar should now be flowing into Darwin.
3.  **Insert SCTE-35 Marker:**
    - The Darwin interface has a feature for live stream manipulation. Guide participants to find the button or control labeled **"Insert SCTE-35 Marker"** or similar.
    - Pressing this button injects the ad signaling marker into the transport stream in real-time. This doesn't change the video content itself but adds metadata that downstream systems will use.
4.  **Configure SRT Output:**
    - Create a new SRT output for the stream that now contains the SCTE-35 marker.
    - **Ensure participants copy the SRT output URL from Darwin**, as it will be the input for Ateme Titan Live.

***

## Challenge 5: Let's Play Out!

https://www.ateme.com/product-titan-software/

### Notes & Guidance

Ateme Titan Live is a broadcast-grade encoder. In this step, participants will configure it to receive the final produced stream and prepare it for delivery over the web. As shown in the architecture diagram, Titan Live is the final step before the stream is handed off to Google Cloud's media services.

1.  **Connect to Titan Live:** Participants should log in to the Titan Live web interface.
2.  **Configure New Input:**
    - They need to create a new input channel.
    - Set the input source type to **SRT**.
    - In the configuration, they will paste the **SRT output URL from Techex Darwin** (from Challenge 3).
3.  **Configure Output/Profile:**
    - The primary goal is to have Titan Live process the stream. A default encoding profile (e.g., H.264/AAC in an HLS format) should be sufficient.
    - The crucial part of the configuration is setting up the destination. In our architecture, Titan Live will hand off to the **Ateme Nea Packager**, which then interfaces with the **Google Cloud Video Stitcher API**. This may be a pre-configured output profile in Titan Live that participants just need to select. The output should be configured to create HLS manifests.

***

## Challenge 6: Get your channel to the masses

### Notes & Guidance

This challenge moves from broadcast-specific tooling to a standard cloud workflow: deploying a web application using a containerized service.

1.  **Clone Git Repository:**
    - Participants need to use a terminal with `gcloud` and `git` installed.
    - They should clone the provided repository for the VideoJS Player.

    ```shell
    git clone [https://github.com/google-cloud-vietnam/ghack-videojs-player.git](https://github.com/google-cloud-vietnam/ghack-videojs-player.git)
    cd ghack-videojs-player
    ```

2.  **Publish to Cloud Run:**
    - The easiest way to deploy is using the `gcloud run deploy` command from the root of the cloned repository. This command will build the container image from the source and deploy it.
    - Participants can name their service whatever they like (e.g., `ghack-player`).
    - The `--allow-unauthenticated` flag is important to make the player publicly accessible for testing.

    ```shell
    gcloud run deploy ghack-player --source . --region europe-west1 --allow-unauthenticated
    ```

    > **Note**: After the deployment succeeds, the command line will output the service URL. **This is the URL for the live channel player.**

***

## Challenge 7: Sit back, relax, and watch TV

### Notes & Guidance

This is the final step where everything comes together. Participants will see their live stream, complete with an advertisement inserted via the Google Cloud Video Stitcher API, triggered by the SCTE-35 marker they inserted earlier.

1.  **Open the Player:**
    - Participants should navigate to the **Cloud Run service URL** they obtained in the previous challenge.
2.  **Verify the Stream:**
    - The VideoJS player should load and start playing the live video feed originating from the Norsk sources, mixed in Vectar, and processed by Darwin and Titan.
3.  **Look for the Ad:**
    - The key to success for this entire hack is seeing an advertisement. The SCTE-35 marker inserted in Challenge 3 signals the Google Cloud Video Stitcher API (via the Ateme components) to insert an ad from Google Ad Manager.
    - When the ad plays, it confirms the entire workflow is functioning correctly. If no ad appears, common issues to troubleshoot are:
        - The SCTE-35 marker was not inserted correctly in Darwin.
        - The integration between Titan Live and the Video Stitcher API is misconfigured.
        - There is an issue with the Google Ad Manager campaign.
