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
- Challenge 4: Sprinkle some AI on it
- Challenge 5: Ready for some Ads?
- Challenge 6: Let's Play Out!
- Challenge 7: Get your channel to the masses

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

- On the downloads page, look in the **Anywhere Clients** section. **NOT** in the Hosts section.
  > [!NOTE]  
  > If the page gets stuck on the splash page, click the browser reload button.

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

Our entire pipeline will be built using **Secure Reliable Transport** protocol streams. SRT is an open source protocol designed to connect two endpoints to deliver low latency video and other media streams across any network including the public internet.

We will gather up all the live and recorded feeds that we have available and bring them into Norsk Studio. Norsk Studio is a live streaming workflow builder with a graphical drag-and-drop UI

This gives us the opportunity to preview the feeds and then create SRT outputs.

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

> [!NOTE]  
> Connecting nodes requires dragging lines between the small circles on the components. If a setting's value is **NOT** specified in these instructions LEAVE THE DEFAULT.

Using the **SRT Ingest (Caller)** component, connect to the 4 provided camera feeds. They are running at the following URIs:

```text
fecamgw01.media.ghacks.dev:5111
fecamgw02.media.ghacks.dev:5112
fecamgw03.media.ghacks.dev:5113
fecamgw04.media.ghacks.dev:5114
```

The settings on the SRT Ingest component will look something like this:

- **Display Name**: `camera1`
- **Host**: `fecamgw01.media.ghacks.dev`
- **Port**: `5111`
- **streamId**: `camera1`

Now add 4 Preview components and connect it to the Ingest components so you can actually see what is coming in. Make sure you don't touch the **Preview Mode** field. It should be: **JPEG Only**.

Finally, add 4 **SRT Listener (Egest)** components and connect them to the sources. Use ports 5111 to 5114.

The settings on the SRT Egest component will look something like this:

- **Display Name**: `srt-listener-camera1`
- **Port**: `5101`
- **Host**: `0.0.0.0`

The final step is to connect your inputs to your outputs. This tells Norsk where to send the media from each source. Your goal is to create four parallel, independent streams.

Save your configuration as a YAML file for future use.

### Success Criteria

- You are ingest 4 camera feeds
- On the Norsk Studio canvas you have Preview components running and showing video for all 4 feeds.
- You've created 4 SRT Egests and noted down their SRT URIs
- You've saved your work as a yaml files and download it as a backup configs.

### Learning Resources

- [Norsk Studio Demo Video](https://youtu.be/6G5OZPv8wRA)
- [Norsk Studio Documentation](https://norsk.video/norsk-studio-live-media-workflow-server/)
- [What is SRT](https://www.haivision.com/blog/all/srt-everything-you-need-to-know-about-the-secure-reliable-transport-protocol/)

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
- In the IP Source Manager dialog that opens, click Add New IP Source
- Select SRT Source in the drop down
- In the Configure SRT Input Connection dialog box that opens, enter `Camera1` in the **Connection Name** field
- To find the server URL, check the internal IP address of the VM named: `norsk-gw-nnn` (where `nnn` is a random string). You can find this name in the Google Cloud console VM list.
  - In this example, it is `10.164.0.5`, yours will be different.
- In the **Server URL** field, enter `srt://10.164.X.X`
- In the port Number enter `5101` which was the port number allocated to SRT Listener Egest camera1 in Norsk.
- Press OK but do not reset your session. We need to add the other cameras first.
- Repeat the above process for Camera 2, Camera 3 and Camera 4, using their respective port numbers.
- To receive the streams, we need to reset Vectar. Go to **File -> Exit** (you will need to position your mouse at the top of the screen to get the File Menu to appear, it's a little tricky).
- Now you are in Kiosk mode. Click **Start Live Production** in the bottom right corner of the screen.
- Vectar takes a while to load again, when it's back you still need to configure the inputs.
- For Input1 Thumbnail, click the **Configure** wheel in the bottom right of the thumbnail
- In the Input1 dialog box, select **Source -> Local -> Camera1**
- Repeat this for the other 3 feeds.

#### Verify Transitions

- After configuring the inputs, the four camera sources should appear in Vectar's source preview monitors.
  > [!NOTE]  
  > It can take up to 2 or 3 minutes for the video to appear in the input's preview windows, please be patient and continue working.
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
  > [!NOTE]  
  > Write down this new SRT output URL for the next challenge.

### Success Criteria

- Your have connected 4 inputs on the Vectar mixing board to the 4 outputs from Norsk Studio used in the last challenge
- You have shown you know how to switch between outputs in Vectar using the **T-Bar** control or **Cut/Auto** buttons.
- You started a stream and have an SRT output URI to use in the next challenge for the next part of our pipeline.

### Tips

To access the remote desktop of the VizRT Vectar VM you will need a GPU accelerated remote desktop client. Regular Windows Remote Desktop will not be able to run VizRT Vectar.

Download the HP Anywhere PCoIP Client for your OS from [this link](https://anyware.hp.com/find/product/hp-anyware)

- On the downloads page, look in the **Anywhere Clients** section
  > [!NOTE]  
  > If the page gets stuck on the splash page, click the browser reload button.

Install the client and then use the credentials provided by your coach to log into the VizRT Vectar workstation VM.

### Learning Resources

- [VizRT Vectar User Guide](https://docs.vizrt.com/viz-vectar-plus-user-guide-1.5.pdf)
- [Getting Started with Vectar (video)](https://youtu.be/bBYKKKJVmuA?t=390)
- [How to Work With Inputs (video)](https://youtu.be/9GlqeAPigTU)
- [VizRT Vectar Product Page](https://www.vizrt.com/products/tricaster/tricaster-vectar/)

## Challenge 4: Sprinkle some AI on it

### Introduction

The way we consume live media is evolving. Viewers no longer just want to watch; they want to engage, analyze, and get real-time insights. The Gemini Live API is a powerful new tool that enables developers to build real-time, interactive experiences by processing live streams of video and audio. This opens up a world of possibilities for a new generation of live media applications.

Your challenge is to build an innovative application using the Gemini Live API that transforms a live media stream from a Formula E race into an intelligent and interactive experience. Your application will process the live video and audio to provide new value to the audience in real time.

### Tools Used

- Gemini Live API
- Norsk Studio (with AI components)

### Description

First we must start with a prompt. The key is to instruct the model on its role and what to look for in the live stream.

For example:

```text
You are a cricket match statistician. I will send you video from a match. For every ball bowled, report on the batsman's current score and the bowler's statistics.
```

Design a prompt that look at the feed of a Formula E race and look for overtakes and then explain what happened.

Log into your Norsk AI instance and replace placeholder with your actual project id:

- URL: <https://gemini.endpoints.[your_project_id].cloud.goog>
- Your coach will provide a username and password

Just as in the last challenge, you will start with a blank canvas in Norsk. On the left is the **Component Library**.

Add a **Camera Feed** component and a **Gemini AI** component to your canvas and connect them.

Configure the Gemini AI Component:

- Give it a name
- Set the API to **Live**
- Update the **System Instructions** by replacing the default text with the prompt you designed.

Now we need to get a **Gemini API Key**

- Go to the Google Cloud Console and search for the **Gemini API** page and enable the API
- On that same page, create credentials of type: **API key**
- Provide a name for your api key : example - Gemini API Key
- In API restrictions section, click radio button Restrict Key
- In the filter select Generative Language API and Vertex AI
- A new API is created, save this key, you'll be using it soon.

Next we will deploy and run the pipeline

- SSH into the Norsk AI instance by finding it's VM in the Google Cloud Console and click the **SSH** button to open a terminal window.
- Add the API key to Norsk's environment by editing this file:
  - `/var/norsk-studio/norsk-studio-docker/env/studio-env`
  - Find the **GOOGLE_API_KEY** variable and paste in your API key
- Restart Norsk by issuing this command:

  ```shell
  sudo systemctl restart norsk
  ```

And finally, let's explore the output we are getting.

Go back to Norsk Studio. Click the Play button to observe the console output from the **Gemini AI** component and see the live commentary.

### Success Criteria

- Created a new Gemini API Key
- Designed a prompt to look for overtakes in a Formula E race
- Connected Gemini Live API to your video feed with commentary/audio feed.
- Real time commentary is being produced by Gemini

### Learning Resources

- [Getting Started with Gemini Live API](https://ai.google.dev/gemini-api/docs/live)

## Challenge 5: Ready for some Ads?

### Introduction

In this challenge, we'll be using TX Darwin to insert ad markers in our stream that we will use later in our pipeline to insert the ads we created in the first challenge.

Techex's TX Darwin is a software-based platform designed for processing, transporting, and monitoring live video workflows in the media industry.

We will be using Darwin specifically for ad insertion into our stream. This means we will be taking the SRT stream that is now coming out of VizRT Vectar and inserting SCTE-35 markers into it.

SCTE-35 markers, colloquially known as "scuddy markers", are a digital signal embedded within a video stream that carries instructions for downstream pipeline elements. They are most commonly used to signal the exact start and end points for inserting ads.

### Tools Used

- Techex TX Darwin

### Description

TX Darwin is a web app running in our environment access through a webpage. Your coach will provide log in details.

#### Configure SRT Ingestion

- Create a new input and configure it to be an **SRT source**.
- Paste the SRT output URL from VizRT Vectar into the ingest configuration. The program feed from Vectar should now be flowing into Darwin.

#### Configure a SCTE-35 Marker

- The Darwin interface has a feature for live stream manipulation. Look for the button labelled **"Insert SCTE-35 Marker"**.
- Pressing this button injects the SCTE-35 marker into the SRT stream in real time, signaling that an ad should be inserted.
- This doesn't change the video content itself but adds metadata that downstream pipeline elements will use.

#### Configure SRT Output

- Create a new SRT output for the stream that now contains the SCTE-35 marker.
  > [!NOTE]  
  > Write down this new SRT output URL for the next challenge.

### Success Criteria

- You've consumed the SRT source from the VizRT Vectar program output
- A SCTE-35 marker has been manually inserted into the stream
- You've configured an SRT output for the next challenges

### Learning Resources

- [SCTE-35 - Their Essential Role for Ad Insertion (video)](https://youtu.be/nEdK2AroyCg)
- [SCTE-35 in TX Darwin](https://www.techex.tv/technologies/txdarwin/transform/technology-module-8)
- [Techex TX Darwin Product Page](https://www.techex.tv/technologies/txdarwin)

## Challenge 6: Let's Play Out!

### Introduction

Now that we have a stream that's ready for broadcast and has SCTE-35 ad insertion markers, we need to encode it for the various devices that will play the stream.

Ateme Titan Live is a broadcast-grade encoder. We will use it to take in the final produced stream and prepare it for delivery over the web. As shown in the architecture diagram, Titan Live and Nea Live are the final step before the stream is handed off to Google Cloud's CDN and used as the origin.

### Tools Used

- Ateme Titan Live for encoding
- Ateme Nea Live for packaging

### Description

First off, log into both Titan and Nea using the credentials given to you by your coach.

```text
- Titan URL: https://titan.endpoints.[your_project_id].cloud.goog
- Nea URL: https://nea.endpoints.[your_project_id].cloud.goog
```

We will first create a new input and set its input source to **SRT** and calling it: **SRT output URL from Techex Darwin**

Then we will configure an output profile using the default: H.264/AAC in an HLS format.

The crucial part of the configuration is setting up the destination. In our architecture, Titan Live will hand off to the **Ateme Nea Packager**, which then interfaces with the **Google Cloud Video Stitcher API**. This is a pre-configured output profile in Titan Live. The output should be configured to create HLS manifests.

> [!IMPORTANT]  
> To achieve the above, you will be following a [step by step guide](https://gfilicetti.github.io/media-on-gcp-ateme-docs/) to configure your pipeline on Ateme Titan and Nea.

### Success Criteria

- Your pipeline input is ingested into Titan Live.
- Your output is encoded with H.264/AAC in an HLS format
- Your output flows into Nea and a package and manifest is produced

### Learning Resources

- [Ateme Titan & Nea Step by Step Setup Guide](https://gfilicetti.github.io/media-on-gcp-ateme-docs/)
- [NEA to CDN Flow (video)](https://youtu.be/bnPkXYyXjOI)
- [Ateme Titan Live Documentation](https://www.ateme.com/product-titan-software/)
- [Ateme Nea Live Documentation](https://www.ateme.com/product-video-content-delivery/)

## Challenge 7: Get your channel to the masses

### Introduction

In this challenge, we now more from broadcast/streaming specific technology and tooling to cloud based app deployment and hosting.

We will deploy a Cloud Run Service that our viewers will connect to with their phones or browsers to view our stream that is served up through a CDN.

Now that we have the end of our pipeline coming from Nea, it serves as the origin of Google Cloud CDN and the player in this challenge is connecting to it.

### Tools Used

- JS Player (open source)
- Google Cloud Run
- Google Cloud CDN
- Google Cloud Shell

### Description

Need to deploy the player application to a Cloud Run service so that it can be consumed by the masses.

Open the Google Cloud shell, and clone this github repository:

```shell
git clone https://github.com/JorgeRSG/sample-video-player.git
cd sample-video-player
```

The easiest way to deploy the player is using the `gcloud run deploy` command from the root of the cloned repository. This command will build the container image from the source and deploy it. Name your service `ghack-player` and make sure to allow public access to the service.

> [!NOTE]  
> If it fails, try a second time, as some services are created on the fly.

> [!NOTE]  
> After the deployment succeeds, the command line will output the service URL. **This is the URL for the live channel**. You can also find the public URL in the Cloud Console on the Cloud Run page.

The VideoJS player should load and start playing the live video feed originating from the Norsk sources, mixed in Vectar, and processed by Darwin and Titan.

The key to success for this entire gHack is seeing an advertisement. The SCTE-35 marker inserted with Darwin signals the Google Cloud Video Stitcher API (via the Ateme components) to insert an ad from Google Ad Manager.

To enable stitching on your stream the Google Cloud Video Stitcher has to be set up.

Go to the Google Cloud console and ssh into the machine called **video-stitch**

Run the command `sudo su - videostitch` to assume the identity of the videostitch user. With it you’ll create your Video Stitcher configuration and start a Video Stitcher session which will return a URI where your ad will be stitched while you watch your stream on the video player.

Use gsutil to copy some configuration files:

```shell
gsutil cp gs://ibc2025-videostitch/* .
```

Before running the scripts you just downloaded, remember to make them executable:

```shell
chmod +x create_config.sh create_session.sh
```

Additionally, the following three variables have to be in place for the scripts to use them. Make sure you replace the values and add them to your terminsal session.

```shell
export SOURCE_HLS_LIVESTREAM_URI="YOUR_SOURCE_HLS_LIVESTREAM_URI"
export AD_GROUP="ASK_YOUR_COACH_FOR_AD_GROUP"
export TEAM_NAME="YOUR_TEAM_NAME"
```

You're now ready to run **create_config.sh** followed by **create_session.sh**

On the output of create_session.sh you’ll see an element called **“Play URI”**. Note that this URI is different from your previous one; your video stitching is ready. Copy that URI and load it in your video player.

> [!NOTE]
> If the session doesn't receive any requests in 5 minutes, it will automatically be closed and you'll have to start a new one. 

Now that content is being played, it is time to insert that ad marker (SCTE35) so that you can see your ad. Go back to the Darwin console from one of the previous challenges and press once the “SCTE Slice Insert - Ad Break Start”.  Wait a few seconds and you’ll see an ad playing in your stream. Once the ad break is over, you’ll see that your stream comes back automatically.

When the ad plays, it confirms the entire workflow is functioning correctly. If no ad appears, common issues to troubleshoot are:

- The SCTE-35 marker was not inserted correctly in Darwin.
- The integration between Titan Live and the Video Stitcher API is misconfigured.
- There is an issue with the Google Ad Manager campaign.

### Advanced Challenge

In a professional setting you will always want to modify the presentation of the player to use your own branding.

To get a feel for how easy it is to update the Cloud Run service, change some of the HTML/CSS code for the player and then issue a `gcloud` command to update the Cloud Run service. (Changing the title of the website and the main header are good options to start with).

### Success Criteria

- You have a Cloud Run service named `ghack-player` deployed
- You can hit the service's public URL and see your stream being played
- Insert a SCTE35 message and watch an ad playing in your stream.
- [Optional] You made some changes to the look and feel of the player and redeployed the service

### Learning Resources

- [Cloud Run Quickstart](https://cloud.google.com/run/docs/quickstart)
- [Deploying to Cloud Run from source code](https://cloud.google.com/run/docs/deploying-source-code)
- [VideoJS Player Repository](https://github.com/JorgeRSG/sample-video-player)
