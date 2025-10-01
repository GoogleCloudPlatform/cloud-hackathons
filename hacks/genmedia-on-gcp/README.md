# Easy Ads: From Concept to Creation with GenMedia

## Introduction

Welcome to the future of advertising! In this workshop, you'll step into the role of a creative director at a cutting-edge ad agency. Your mission is to create a compelling 20-30 second video advertisement for a revolutionary new product.

![Challenge Overview](./images/easy-ads-overview.png)

This isn't about writing code. It's about mastering the art of the prompt. You will use Google Cloud's generative AI tools within Vertex AI Studio to bring your vision to life. The challenge lies in guiding these models to produce a final ad that is not just aesthetically pleasing, but also **coherent, consistent,** and **on-brand,** complete with **multilingual voice-over**, graphic overlays and a **custom soundtrack**.

## Learning Objectives

This hack will help you master the following skills:

- Advanced Prompt Engineering  
  - Crafting detailed prompts to control style, composition, and object consistency.  
- Consistent Generation  
  - Creating a believable product and protagonist and maintaining their appearance across different shots.  
- Text-to-Image Generation  
  - Composing a set of graphical elements to enhance the visual appeal of the ad and convey brand information: logos, taglines, etc.  
- Text-to-Video Generation  
  - Directing AI to create dynamic, high-quality video clips from text and image prompts.  
- Text-to-Speech Generation  
  - Creating a professional voice-over in multiple languages.  
- Text-to-Music Generation
  - Composing a custom soundtrack that matches the mood of the ad.  
- Video Assembly  
  - Stitching generated visual and audio assets into a final, polished video.

## Challenges

- Challenge 1: From Product to Narrative  
- Challenge 2: The Visual Blueprint  
- Challenge 3: From Stills to Motion  
- Challenge 4: The Assembly  
- Challenge 5: Giving It a Voice  
- Challenge 6: The Soundtrack  

## Prerequisites

- Basic understanding of generative AI concepts (text-to-image, text-to-video, text-to-speech).  
- Access to a Google Cloud project with Vertex AI Studio enabled, including access to Imagen, Veo, Chirp, and Lyria models.  
- Access to a basic video editing tool (e.g., Google Vids, DaVinci Resolve, Adobe Premiere Pro, CapCut, iMovie, or any online editor).

## Contributors

- Murat Eken  
- Gino Filicetti  
- Jeff Katzen  
- Justin Grayston

## Challenge 1: From Product to Narrative

### Introduction

Every ad starts with a product and tells a story to sell that product. In this challenge we'll introduce the product and come up with brand guidelines for the product, design a story and a character while making sure everything stays coherent.

#### The Product

The **Cymbal Pod** is a single person, urban transport vehicle that hovers silently and moves quietly through the world.

### Description

Start by designing the **brand guidelines**, include at least the *aesthetics* (e.g. 1920s art deco) and the *values* (e.g. sustainable farming) that you want to convey. These characteristics will guide all the visuals we create for the product.

Next, create a description of your **protagonist** who is the main character of your ad. This description needs to be detailed enough so that we can achieve consistency from shot to shot in the ad.

Now, we'll craft an **overall narrative** to tell the story of the *Cymbal Pod* and what makes it compelling. We will do this by creating textual descriptions of at least **three scenes** describing what happens in each scene and how they tie together to tell your story.

And finally, create **a tagline or call to action** that meets the brand guidelines (e.g Available for pre-order now*)*. We'll use that text in our final ad video.

We've created a storage bucket with the same name as your project id, navigate there, and upload a text document with all this information into that bucket.

### Success Criteria

- You have created a set of brand guidelines at a minimum describing the *aesthetics* and the *values* of the brand.  
- You have created a detailed text description of the protagonist of your narrative.  
- You have created a text description/script for at least three scenes that seamlessly tell your story.  
- You have created a tagline or call to action that meets the brand guidelines.  
- You've stored all of this information in a text document on the provided storage bucket.

### Learning Resources

- [Storytelling in the Ad Creative Process](https://mailchimp.com/resources/storytelling-in-marketing)  
- [Gemini Prompts for Ad Copy](https://felloai.com/2025/08/7-effective-gemini-prompts-for-ad-copy-that-actually-bring-results/)

### Tips

- When you are in need of creative inspiration, you are free to use Gemini in clever ways.

## Challenge 2: The Visual Blueprint

### Introduction

Now that we have our brand guidelines, our protagonist and our narrative, it's time to create our visuals. This is the **storyboard** of your ad, which visually shows the flow of your narrative and your protagonist within it.

### Description

First we will create our **protagonist**. Using *Imagen*, generate a character “model sheet” and “turnaround” images for your protagonist using your description of them and your brand guidelines. The model sheet standardizes a character's appearance, poses, and gestures, while the turnaround images depict the character at different angles.

Next, create images for your **storyboard** visualizing the scenes crafted in the previous challenge.

We also need a **final closing frame** that will inform Veo on how to end the video. It should include space for a Cymbal Pod logo and space for the text of the tagline or call to action.

Finally, use *Imagen* to generate **a logo** for the Cymbal Pod that conveys the brand. Save these images for later use when we compose our final video.

**IMPORTANT:** In this gHack we will be producing horizontal landscape video (16:9) format.

Make sure that all of this work is stored in the storage bucket that has been created for you.

### Success Criteria

- One model sheet image is generated that clearly defines the **protagonist's appearance**.  
- Two turnaround images are generated showing the protagonist in back and side views.  
- You have generated **distinct storyboard images** and a **final closing frame image**.  
- The *Cymbal Pod*'s design is *visibly consistent* across all storyboard images.  
- The protagonist's appearance is *visibly consistent* across all storyboard images.  
- The overall aesthetic is *consistent* and conforms to your brand guidelines.  
- Your coach approves of the visual consistency of your images.  
- The images are stored in the storage bucket that has been provided to you.

### Learning Resources

- [Introduction to Vertex AI Studio](https://cloud.google.com/vertex-ai/docs/studio/introduction)  
- [Generate images with Imagen](https://cloud.google.com/vertex-ai/docs/generative-ai/image/generate-images)  
- Model sheet  
- Turnaround images

## Challenge 3: From Stills to Motion

### Introduction

With your storyboard and protagonist created, it's time to bring your vision to life. This challenge is about converting your static scenes into dynamic video clips.

### Description

Using the *Veo* family of models in Vertex AI Studio, generate video clips for each of your storyboard scenes from Challenge 2. Make sure you use your generated images as references in your prompts to guide the model.

**IMPORTANT:** For this challenge, generate the videos **without any audio**. We will add sound in later stages.

You know the drill, once finished, store the resulting clips in the storage bucket provided to you.

### Success Criteria

- High-quality, 5-7 second video clips for each of the storyboard scenes are generated.  
- The video aesthetics are *highly consistent* with the corresponding static images.  
- The motion depicted is *smooth* and *realistic*.  
- When viewed in sequence, the clips form a coherent narrative, with logical transitions.  
- Your coach approves of the visual consistency of your videos and their fidelity to your storyboard images.  
- The videos have been stored in the storage bucket that has been provided to you.

### Learning Resources

- [Generate videos with Veo](https://cloud.google.com/vertex-ai/docs/generative-ai/video/generate-videos)

## Challenge 4: The Assembly

### Introduction

You have all your visual components. Now it's time for post-production. In this challenge, you'll act as the editor, assembling the generated clips into a single, seamless advertisement.

### Description

Using a video editor of your preference, stitch together the video clips you created in Challenge 3\. The goal is to create a single, cohesive video file that flows logically and tells the intended story.

To close out the ad, add in the Cymbal Pod logo and any other static graphics you created in Challenge 2\. Don't forget to add your tagline or call to action here as well.

**NOTE:** You could use Imagen for generating text as well, but in case you're not getting what you want, you can just use text elements within your video editor.

### Success Criteria

- The video is 20-30 seconds long.  
- The video tells a coherent story, using the shots generated in the previous challenge.  
- The final assembled video is free of jarring cuts, ridiculous transitions (no star wipes!) or continuity errors.

### Tips

- [Google Vids](http://vids.google.com) is a great and free service for editing videos

## Challenge 5: Giving It a Voice

### Introduction

A silent film can be powerful, but a voice-over can deliver a targeted message. In this challenge, we'll generate a set of professional-sounding voice-overs for your ad with at least one voice-over in a foreign language, making your campaign global-ready.

### Description

First, write a short, compelling script for your ad. The script should consist of multiple pieces of voice-over audio to be inserted into your ad in different spots. The script should align with the brand guidelines you've defined. Gemini is fair game to generate the script, or you're free to use your own writing creativity.

Next, use the *Chirp* model in Vertex AI or *Gemini* itself to generate the voice-overs from your script. Choose one of the voice-overs and generate it in a foreign language, (e.g. Italian, Afrikaans, Turkish).

Finally, add these audio tracks to the video you assembled in Challenge 4 in the proper places in your video sequence timeline.

### Success Criteria

- A short, on-brand script is written describing multiple voice-overs needed in the ad.  
- Multiple high-quality voice-overs are generated with at least **one** in a foreign language.  
- The voice-overs are successfully added to the video file, with timing that matches the visuals.

### Learning Resources

- [Create voice-overs with Chirp](https://cloud.google.com/text-to-speech/docs/chirp3-hd)  
- [Create voice-overs with Gemini](https://cloud.google.com/text-to-speech/docs/gemini-tts)

## Challenge 6: The Soundtrack

### Introduction

Music is an important layer of emotion in your ad. To complete your masterpiece, you will use Google's *Lyria* model to compose a custom piece of background music that complements the visuals and voice-over.

### Description

Using the *Lyria* model in Vertex AI, generate a music track for the entire ad. Remember to adhere to your brand guidelines.

Once you have a track you're happy with, add it as a final audio layer to your video sequence timeline. Make sure to balance the volume so that the music complements the voice-overs without overpowering them.

### Success Criteria

- A music track is generated for the entire length of the ad.  
- The music's mood and style align with the brand guidelines.  
- The music is successfully added to the video, creating a final, polished ad with visuals, voice-over, and a soundtrack.  
- You've exported your final ad as an **MP4** file.
