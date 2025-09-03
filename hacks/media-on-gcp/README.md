# Media & Entertainment on Google Cloud

## Introduction

The Media & Entertainment on Google Cloud gHack will take you on a whirlwind tour in the world of media technology and how it is being used in the modern world of cloud based and AI services.

![Overview](./images/media-on-gcp-overview.png)

In this gHack we will be ingesting feeds from a variety of sources: live SRT feeds, camera feeds, stored files and running it through a media switching workflow where you will collect the feeds, send them to a switcher, set up the playout on a FAST channel, setup HLS/DASH encoding for mobile and make it available to users over a CDN.

In addition to this, there will be a creative portion to this gHack where you will be using Google Clouds AI creation tooling: Veo, Imagen and Lyra to create shots and then edit them together in a video editor to create an advertisement. This will then be sent to Google Ad Manager and consequently using the Google Video Stitcher API the advert will be added to your FAST channel at various points.

## Learning Objectives

In this hack you will get hands on experience with both first party Google Cloud tooling for media as well as third party tools that are industry standards and used extensively in the ecosystem:

### Google Cloud First Party
- Veo for AI driven video generation
- Imagen for AI driven image generation
- Lyra for AI driven music generation
- Gemini Live API for inference on live streams
- Google Ad Manager & Video Stitcher API for ad insertion and delivery
- Google Cloud CDN for delivery of video feeds to end users
- Google Cloud Compute & Storage for the backbone of everything

### Media Technology Partners
- Norsk for Routing SRT Video Streams
- VizRT Vectar for video switching / Vision mixing
- TechEx Darwin for inserting SCTE-35 Ad Markers
- Ateme Titan Live for Encoding
- Ateme Nea Live for ABR Packaging
- Davinci Resolve for remote video editing

## Challenges

- Challenge 1: Get creative with the help of AI
- Challenge 2: Gather up those feeds and spit 'em out
- Challenge 3: Get in the Mix
- Challenge 4: Ready for some Ads?
- Challenge 5: Let's Play Out!
- Challenge 6: Get your channel to the masses
- Challenge 7: Sit back, relax, and watch TV

## Prerequisites

- Basic knowledge of GCP
- Access to a GCP environment
- Licenses for the third party software 

## Contributors

- Chris Hampartsoumian
- Jorge Sanchez
- Chanka Perera
- Gino Filicetti
- Michael Bychkowski

## Challenge 1: Get creative with the help of AI

### Introduction
Using Google Cloud's Generative Media offerings can make quick work of ad creative generation. In this challenge we'll get a taste of doing just that and create an ad videos that we will use later in this gHack to insert into our video stream.

### Tools Used
- Google Cloud's Media Studio for Generative AI: Veo, Imagen and Lyra
- HP Anywhere PCoIP for GPU accelerated remote desktop access (formerly known as Teradici)
- Blackmagic DaVinci Resolve for professional video editing 

### Description
You will work as a team and get creative to come up with an imaginary product. Then use your creativity to create an ad for that product.

In the Google Cloud Console and find **Media Studio** within the **Vertex AI** suite. 

In the **Media Studio** you have access to the generative AI creative tooling. 
- Use Veo to create shots. 
- Use Imagen to create still images. 
- Use Lyra to create music

You are welcome to produce the final ad using only Veo if you'd like, but if you want to make it more professional, you'll need to editing your shots, music and stills together.

We have provided a virtual workstation with Blackmagic's DaVinci Resolve video editor. You can use it to create a nicely produced ad video. Your coach will provide log in details. See the **Tips** section below for instructions on installing the client and connecting to the workstation. Only one team member needs to install this.

Your final result should be one or two 30 second ad videos that use multiple shots generated in Veo and scored with music created in Lyra. If you want to weave in some still images, these are created with Imagen.

Try to complete this challenge in 90 minutes to give yourselves enough time for the rest of the gHack. This challenge can be worked on independently from the rest of the gHack. If there are team members that want to focus more on video editing, that's fine. 

Each team should upload a maximum of 2 ad videos to your assigned Google Cloud Storage bucket sub-folder. This will be given do you by your coach and will look something like: `gs://hackfest-ad-creative/[your_project_id]/`

### Success Criteria
- You have created one or two 30 second ad videos.
- Only the Google Cloud generative media suite was used to produce the source material:
    - Veo
    - Imagen
    - Lyra
- You have uploaded your videos as `mp4` files to your assigned bucket sub-folder.

### Tips
To access the remote desktop of the DaVinci Resolve VM you will need a GPU accelerated remote desktop client. Regular Windows Remote Desktop will not be able to run DaVinci Resolve.

Download the HP Anywhere PCoIP Client for your OS from [this link](https://anyware.hp.com/find/product/hp-anyware)
    - On the downloads page, look in the **Anywhere Clients** section
    - **NOTE:** If the page gets stuck on the splash page, click the browser reload button.

Install the client and then use the credentials provided by your coach to log into the DaVinci Resolve workstation VM.

### Learning Resources
- [Veo video generation overview](https://cloud.google.com/vertex-ai/generative-ai/docs/video/overview)
- [Imagen image generation overview](https://cloud.google.com/vertex-ai/generative-ai/docs/image/overview)
- [Lyra music generation overview](https://cloud.google.com/vertex-ai/generative-ai/docs/music/generate-music)
- [DaVince Resolve Beginners Guide Video (13 min)](https://youtu.be/SzttF-qnqsM)
- [DaVinci Resolve New Features Guide](https://documents.blackmagicdesign.com/SupportNotes/DaVinci_Resolve_20_New_Features_Guide.pdf)
- [HP Anywhere PCoIP Downloads](https://anyware.hp.com/find/product/hp-anyware)


## Challenge 2: Gather up those feeds and spit 'em out

### Introduction
It is now time to start working on end to end media streaming pipeline. It all begins from our raw source feeds.

We will gather up all the live and recorded feeds that we have available and bring them into Norsk Studio. Norsk Studio is a live streaming workflow builder with a graphical drag-and-drop UI

This gives us the opportunity to preview the feeds and then create SRT outputs. SRT (Secure Reliable Transport) is an open-source video transport protocol designed to deliver high-quality, low-latency video securely over unpredictable networks like the public internet.

Once we have SRT outputs, we will be using them later in our pipeline.

### Tools Used
- Google Cloud Compute Engine
- Norsk Studio 

### Description
We will be using Norsk Studio as our gateway to collect all our feeds. Norsk is where our pipeline begins.

Log into your Norsk instance and replace placeholder with your actual project id:
- URL: <https://norsk.endpoints.[your_project_id].cloud.goog>
- Your coach will provide a username and password

You will start with a blank canvas in Norsk. On the left is the **Component Library**. We will be dragging components onto our canvas and connecting them to build up this part of the pipeline.

**NOTE:** Connecting nodes requires dragging lines between the small circles on the components.

Using the **SRT Ingest (Caller)** component, connect to the 4 provided camera feeds. They are running at the following URIs:
```
srt://34.32.228.47:5001
srt://34.34.228.47:5001
srt://34.32.34.47:5001
srt://34.32.228.34:5001
```

The settings on the SRT Ingest component will look something like this:
- **displayName**: `camera1`
- **host**: `34.32.228.47` 
- **port**: `5001`
- **streamId**: `camera1`

Now add 4 Preview components and connect it to the Ingest components so you can actually see what is coming in.

Finally, add 4 **SRT Listener (Egest)** components and connect them to the sources. Use ports 5101 to 5104.

The settings on the SRT Egest component will look something like this:
- **displayName**: `srt-listener-camera1`
- **port**: `5101`

The final step is to connect your inputs to your outputs. This tells Norsk where to send the media from each source. Your goal is to create four parallel, independent streams.

Save your configuration as a YAML file for future use.

**NOTE:** Write down the SRT URIs for your Egest components, these will be used in the next stage of the pipeline.

### Success Criteria
- You are ingest 4 camera feeds
- On the Norsk Studio canvas you have Preview components running and showing video for all 4 feeds.
- You've created 4 SRT Egests and noted down their SRT URIs

### Learning Resources
- [Norsk Studio Demo Video](https://youtu.be/6G5OZPv8wRA)
- [Norsk Studio Documentation](https://norsk.video/norsk-studio-live-media-workflow-server/)

## Challenge 3: Get in the Mix

### Introduction
In this challenge, we'll be bringing our feeds into a vision mixer and creating a program output that will be used in our pipeline.

You will work with a professional vision mixer, VizRT Vectar. 

First you will wire up the mixing board inputs with feeds from the previous step.

Then using some creative art direction, you'll be producing a program out. "PGM" or program out is a single video feed from a vision mixer that represents the final, switched, live output intended for broadcast, streaming, or recording.

We will be using VizRT Vectar as a virtual appliance. It runs on VM to which we'll connect with our GPU accelerated remote desktop client: HP Anywhere PCoIP.

### Tools Used
- VizRT Vectar
- HP Anywhere PCoIP for GPU accelerated remote desktop access (formerly known as Teradici)

### Description
We have provided a virtual workstation with the VizRT Vectar vision mixer. Your coach will provide log in details. See the **Tips** section below for instructions on installing the client and connecting to the workstation. Only one team member needs to install this.

#### Configuring Inputs
- Within the Vectar interface, press the **Setup** button at the top of the screen
- Locate input 1 in the setup screen and click the **Configure** wheel at the end of the row.
- In the dialog that opens, find the **source** drop down menu and choose: **Local -> Add IP Source...**
- In the Source Manager dialog that opens, click the **Configure** wheel next to `camera1`
- In the Configure SRT Input Connection dialog box that opens, enter `Camera1` in the **Connection Name** field
- To find the server URL, check the internal IP address of the VM named: `norsk-gw-nnn` (where `nnn` is a random string). You can find this name in the Google Cloud console VM list. 
    - In this example, it is `10.164.0.5`, yours will be different.
- In the **Server URL** field, enter `srt://10.164.0.5`
- In the port Number enter `5111` which was the port number allocated to camera1 in Norsk.
- Press OK but do not reset your session. We need to add the other cameras first.
- Repeat the above process for Camera 2, Camera 3 and Camera 4
- To receive the streams, we need to reset Vectar. Go to **File -> Exit** (you will need to position your mouse at the top of the screen to get the File Menu to appear, it's a little tricky).
- Now you are in Kiosk mode. Click **Start Live Production** in the bottom right corner of the screen.
- Vectar takes a while to load again, when it's back you still need to configure the inputs.
- For Input1 Thumbnail, click the **Configure** wheel in the bottom right of the thumbnail
- In the Input1 dialog box, select **Source -> Local -> Camera1**
- Repeat this for the other 3 feeds.

#### Verify Transitions
- After configuring the inputs, the four camera sources should appear in Vectar's source preview monitors.
- Try out all the switcher controls. 
    - Click on sources to put them in **Preview** and use the **T-Bar** or **Cut/Auto** buttons to transition them to **Program**. This confirms that the streams are correctly ingested and that Vectar is operational.

#### Configure SRT Output
- Similar to Norsk, you need to configure an output stream. This is typically done in the **Output** or **Streaming** settings.
- To configure the output, locate the **STREAM** button in the top menu, press the **Configure** wheel next to it.
- Locate the output labelled **SRT Stream** that has a tick mark next to it. Click the **Configure** wheel to the right of it.
- In the **Configure SRT Connection** dialog box, choose **Connection Type -> Host Local SRT Stream**
- Leave the **Server Port** at **10000**
- Now press the **STREAM** button at the top of the screen. 
- You must set the output type to **SRT**. Vectar will provide a new SRT URL for its program output.
- **NOTE:** Please note down this new SRT output URL for the next challenge.

### Success Criteria
- Your have connected 4 inputs on the Vectar mixing board to the 4 outputs from Norsk Studio used in the last challenge
- You have shown you know how to switch between outputs in Vectar using the **T-Bar** control or **Cut/Auto** buttons.
- You started a stream and have an SRT output URI to use in the next challenge for the next part of our pipeline.

### Tips
To access the remote desktop of the VizRT Vectar VM you will need a GPU accelerated remote desktop client. Regular Windows Remote Desktop will not be able to run VizRT Vectar.

Download the HP Anywhere PCoIP Client for your OS from [this link](https://anyware.hp.com/find/product/hp-anyware)
    - On the downloads page, look in the **Anywhere Clients** section
    - **NOTE:** If the page gets stuck on the splash page, click the browser reload button.

Install the client and then use the credentials provided by your coach to log into the VizRT Vectar workstation VM.

### Learning Resources
- [VizRT Vectar User Guide](https://docs.vizrt.com/viz-vectar-plus-user-guide-1.5.pdf)
- [Getting Started with Vectar (video)](https://youtu.be/bBYKKKJVmuA?t=390)
- [How to Work With Inputs (video)](https://youtu.be/9GlqeAPigTU)
- [VizRT Vectar Product Page](https://www.vizrt.com/products/tricaster/tricaster-vectar/)

## Challenge 4: Ready for some Ads?

### Introduction
- Connect to Techex Darwin
- Connect the SRT ingest point to the output from VizRT Vectar in the previous step
- Press the button in Techex Darwin to insert a SCTE-35 marker into the program out stream
- Configure the SRT output

### Description

1.  **Connect to Techex Darwin:** 
    - URL: https://darwin.endpoints.[your_project_id].cloud.goog
    - Your coach will provide the username and password.
2.  **Configure SRT Ingest:**
    - Create a new input and configure it to be an **SRT source**.
    - Paste the SRT output URL from VizRT Vectar into the ingest configuration. The program feed from Vectar should now be flowing into Darwin.
3.  **Insert SCTE-35 Marker:**
    - The Darwin interface has a feature for live stream manipulation. Guide participants to find the button or control labeled **"Insert SCTE-35 Marker"** or similar.
    - Pressing this button injects the ad signaling marker into the transport stream in real-time. This doesn't change the video content itself but adds metadata that downstream systems will use.
4.  **Configure SRT Output:**
    - Create a new SRT output for the stream that now contains the SCTE-35 marker.
    - **Ensure participants copy the SRT output URL from Darwin**, as it will be the input for Ateme Titan Live.

### Success Criteria
- You've consumed the SRT source from your VizRT Vectar configuration
- A SCTE marker is in place
- You've configured an SRT output for the next challenges

### Learning Resources
- [Techex Darwin Documentation](https://www.techex.tv/technologies/txdarwin)

## Challenge 5: Let's Play Out!

### Introduction
- For Ateme Titan Live and Nea follow [this guide](https://gfilicetti.github.io/media-on-gcp-ateme-docs/).

### Description
Ateme Titan Live is a broadcast-grade encoder. In this step, participants will configure it to receive the final produced stream and prepare it for delivery over the web. As shown in the architecture diagram, Titan Live is the final step before the stream is handed off to Google Cloud's media services.

1.  **Connect to Titan Live:** 
    - URL: https://titan.endpoints.[your_project_id].cloud.goog
    - Your coach will provide the username and password.
1.  **Connect to Nea:** 
    - URL: https://nea.endpoints.[your_project_id].cloud.goog
    - Your coach will provide the username and password.
2.  **Configure New Input:**
    - Create a new input channel.
    - Set the input source type to **SRT**.
    - In the configuration paste the **SRT output URL from Techex Darwin**
3.  **Configure Output/Profile:**
    - The primary goal is to have Titan Live process the stream. A default encoding profile (e.g., H.264/AAC in an HLS format) should be sufficient.
    - The crucial part of the configuration is setting up the destination. In our architecture, Titan Live will hand off to the **Ateme Nea Packager**, which then interfaces with the **Google Cloud Video Stitcher API**. This may be a pre-configured output profile in Titan Live that participants just need to select. The output should be configured to create HLS manifests.

### Success Criteria
- Your channel is running and live
- A processed stream is available

### Learning Resources
- [Ateme Titan Live Documentation](https://www.ateme.com/product-titan-software/)

## Challenge 6: Get your channel to the masses

### Introduction
- Clone Git hub repo for VideoJS Player
- Publish to Cloud Run
- Edit the code of the website and deploy the updated version (optional)

### Description

This challenge moves from broadcast-specific tooling to a standard cloud workflow: deploying a web application using a containerized service.

1.  **Clone Git Repository:**
    - Participants need to use a terminal with `gcloud` and `git` installed.
    - They should clone the provided repository for the VideoJS Player.

    ```shell
    git clone https://github.com/JorgeRSG/sample-video-player.git
    cd sample-video-player
    ```
2.  **Publish to Cloud Run:**
    - The easiest way to deploy is using the `gcloud run deploy` command from the root of the cloned repository. This command will build the container image from the source and deploy it. You can find more information [here](https://cloud.google.com/run/docs/deploying-source-code) 
    - Participants can name their service whatever they like (e.g., `ghack-player`).
    - The `--allow-unauthenticated` flag is important to make the player publicly accessible for testing.

    ```shell
    gcloud run deploy ghack-player --source . --region europe-west1 --platform managed --allow-unauthenticated
    ```

    > **NOTE**: After the deployment succeeds, the command line will output the service URL. **This is the URL for the live channel player.**
3.  **Edit the code of the website and deploy the updated version (optional):**
    - Participants can change the look and feel of the published service if they want to. Open the code of the repository in the IDE of your choice and make some edits. Changing the title of the website and the main header are good options.
    - Once the changes are made, save the files and the new version of the service.

### Success Criteria
- You have a player running in your own Cloud Run service
- The player works in your browser and in anyone's browser

### Learning Resources
- [Cloud Run Quickstart](https://cloud.google.com/run/docs/quickstart)
- [Sample Video Player Repository](https://github.com/JorgeRSG/sample-video-player)

## Challenge 7: Sit back, relax, and watch TV

### Introduction

This is the final step where everything comes together. Participants will see their live stream, complete with an advertisement inserted via the Google Cloud Video Stitcher API, triggered by the SCTE-35 marker they inserted earlier.

### Description

1.  **Open the Player:**
    - Participants should navigate to the **Cloud Run service URL** they created in the previous challenge.
2.  **Verify the Stream:**
    - The VideoJS player should load and start playing the live video feed originating from the Norsk sources, mixed in Vectar, and processed by Darwin and Titan.
3.  **Look for the Ad:**
    - The key to success for this entire hack is seeing an advertisement. The SCTE-35 marker inserted in Challenge 3 signals the Google Cloud Video Stitcher API (via the Ateme components) to insert an ad from Google Ad Manager.
    - When the ad plays, it confirms the entire workflow is functioning correctly. If no ad appears, common issues to troubleshoot are:
        - The SCTE-35 marker was not inserted correctly in Darwin.
        - The integration between Titan Live and the Video Stitcher API is misconfigured.
        - There is an issue with the Google Ad Manager campaign.

### Success Criteria
- Are you not entertained!?!

### Learning Resources
- [Yes We Are...](https://youtu.be/HmdpjkM3onk?si=t9_hnBoU4HBKeWZS&t=76)
