# Easy Ads: From Concept to Creation with GenMedia

## Introduction
This is the coach's guide for the **Easy Ads: From Concept to Creation with GenMedia** gHack. Here you will find specific guidance for coaches for each of the challenges.

> [!NOTE]  
> If you are a gHacks participant, this is the answer guide. Don't cheat yourself by looking at this guide during the hack!

## Coach's Guide

This isn’t about writing code. It’s about mastering the art of the prompt. You will use Google Cloud’s generative AI tools within Vertex AI Studio to bring your vision to life. The challenge lies in guiding these models to produce a final ad that is not just aesthetically pleasing, but also coherent, consistent, and on-brand, complete with multilingual voice-over, graphic overlays and a custom soundtrack.

### Learning Objectives

This hack will help you master the following skills:

* **Advanced Prompt Engineering**  
  * Crafting detailed prompts to control style, composition, and object consistency.  
* **Consistent Generation**  
  * Creating a believable product and protagonist and maintaining their appearance across different shots.  
* **Text-to-Image Generation**  
  * Composing a set of graphical elements to enhance the visual appeal of the ad and convey brand information: logos, taglines, etc.  
* **Text-to-Video Generation**  
  * Directing AI to create dynamic, high-quality video clips from text and image prompts.  
* **Text-to-Speech Generation**  
  * Creating a professional voice-over in multiple languages.  
* **Text-to-Music Generation**  
  * Composing a custom soundtrack that matches the mood of the ad.  
* **Video Assembly**  
  * Stitching generated visual and audio assets into a final, polished video.


## General Guidelines


* Google's models prioritize IP and safety with the utmost seriousness.  
* Refrain from using any known persons (celebrities), products, films, references, likenesses, or names. Doing so will trigger safety filters within Gemini.  
* Avoid including child characters in your storyline.  
* When crafting prompts, infuse as many details as possible regarding your character, scene, and product.  
* Google Vids serves as an excellent tool for combining videos and adding voice-overs; however, you are free to utilize any other preferred editing software.


## Only for Classroom Setting : How to access the Google Cloud Console

#### Only for Team Leads

* Team leads are identified by Coach  
* **One account per team** and will **permit five shared logins.**   
* Coach will send requests Team leads to register their Qwiklabs account.  Once loggedin Team Lead can share the credentials to the rest of the team.   

Login : [https://explore.qwiklabs.com/](https://explore.qwiklabs.com/)  
- Use Your Email  
- Fill out registration details ( Name, DOB etc )  
- You should see a Lab. 
- Clicking the Lab will take you to the another page, click the radio button to click - Start Lab ( Green Button ) 
- In couple of mins this page will refresh and show you five shared logins, share with your team.


## Challenges

- Challenge 1: From Product to Narrative
- Challenge 2: The Visual Blueprint  
- Challenge 3: From Stills to Motion  
- Challenge 4: The Assembly  
- Challenge 5: Giving It a Voice  
- Challenge 6: The Soundtrack  

## Challenge 1: From Product to Narrative
#### Estimated time: 25-30 Mins
 You will define the brand guidelines, detailed descriptions for the protagonist and product, and a 3-scene narrative/script.

### Introduction

Every ad starts with a product and tells a story to sell that product. In this challenge we’ll introduce the product and come up with brand guidelines for the product, design a story and a character while making sure everything stays coherent.

### The Product

The **Cymbal Pod** is a single person, urban transport vehicle that hovers silently and moves quietly through the world.

**Note:**  
*This challenge is all about **building our story and characters**, we’re expecting you to **creatively craft descriptions**, and **use Gemini to provide details** and **embellishments** to the story text. We will use these texts in the subsequent challenges to create prompts. So, **your descriptions should be detailed enough to capture the essence of your story,** but keep in mind that we’re not designing prompts yet.* 

### Description

First, **create a document that’s shared with your whole team**, so you can collaborate and keep track of your work.

Then, start by designing the **brand guidelines**, these should include:

- *Aesthetics (e.g. 1920s art deco)*  
- *Values (e.g. sustainable farming)*  
- *Mood / Color Palette (e.g. film noir)*  
- *Target Audience (e.g. 20-35 year old farmers or IT worker, or someone else)*  
- *These characteristics will guide all the visuals we create for the product.*

1. Next, create a description of your **protagonist** who is the main character of your ad. This description needs to be detailed enough so that we can achieve consistency from shot to shot in the ad.  
2. Next, create a description of your **product**. This description needs to be detailed enough so that we can achieve consistency from shot to shot in the ad.  
3. Now, we’ll craft an **overall narrative** to tell the story of the Cymbal Pod and what makes it compelling. We will do this by creating textual descriptions of at three scenes describing what happens in each scene and how they tie together to tell your story.  
4. And finally, create a **tagline** or **call to action** that meets the brand guidelines (e.g Available for pre-order now). We’ll use that text in our final ad video.

### Note

* Use Gemini in this challenge in order to generate ideas, narrative and storylines.   
* If using Gemini make sure that you keep its output brief and clear.  
* Although Gemini will help with inspiration, it will generate similar (and rather bland) ideas if you enter the challenge description in verbatim (we’ve seen far too often an architect called Elara to be the protagonist). Use your and your team's creativity to create a unique protagonist and scene (not the default ideas that Gemini generates)  
* A key criteria for winning is to be as creative and unique as possible.

>### Pro Tips

* Take **5 mins** with your team discussing what the brand guidelines, product and protagonist should be like. Be creative\! Don't waste time here.   
* See the example below and use Gemini to help you write.  
* Focus on your story and keep in mind that you have 20-30 seconds to tell that story. Each scene is about 8 seconds.  
* Don’t try to squeeze too many different things in a single scene. Keep it simple.  
* Parallelize your work.   
  * One person can work on the POD/vehicle/Product design  
  * One person on Styling \- Think about your favourite movie and their color pallets. [Some ideas here](https://digitalsynopsis.com/design/cinema-palettes-famous-movie-colors/#google_vignette)  
  * One person on the Protagonist  
  * Rest work on a storyline/narrative.

>### Deliverables
Document shared with the team that includes:  
- Brand Guidelines  
- Product Description  
- Protagonist  
- Narrative

>### Success Criteria

- You have created a set of **brand guidelines** describing the aesthetics, values, mood/color palette and target audience for the brand.  
- You have created a detailed text description of the **product**.  
- You have created a detailed text description of the **protagonist** of your narrative.  
- You have created a text description/script for three scenes that seamlessly tell your story as a **narrative**.  
- You have **created a tagline or call to action** that meets the brand guidelines.  
- Your work is stored in a **shared document that’s accessible by your team.**

### Learning Resources

[Gemini Prompts for Ad Copy](https://felloai.com/2025/08/7-effective-gemini-prompts-for-ad-copy-that-actually-bring-results/)  
[Storytelling in the Ad Creative Process](https://mailchimp.com/resources/storytelling-in-marketing)

## Challenge 2: The Visual Blueprint
#### Estimated Time: 40 mins

### Introduction

Now that we have our **brand guidelines,** our **protagonist** and our **narrative**, it’s time to create our visuals. This is the **storyboard** of your ad, which visually shows the flow of your narrative and your protagonist within it.

### Description
First we will create our protagonist. Using Gemini Native Image (aka: **Nano Banana**), generate a representative image of your protagonist using your description of them and your brand guidelines. 

### Tips
* The images must be in 16:9 format because we’ll use them as references for the video clips we’ll create in the next challenge*
* You should create the protagonist and the product as a team. The scenes, logo and call to action can be done in parallel.*  
* *Keep in mind that some models will have limitations with respect to how many reference images you can include in a prompt and the maximum size. See for example the [Technical Specifications for Nano Banana](https://cloud.google.com/vertex-ai/generative-ai/docs/models/gemini/2-5-flash-image)*  
* *There are also limits in the Media Studio UI, you might want to use the Import from Cloud Storage options instead of uploading your images in your prompt.*  
* *You should absolutely use the ‘Help me write’ feature or use Gemini to create the right & detailed prompts for you to use.*

Once you have your protagonist images, generate more images that depict the protagonist at different angles (front, side, back, 3/4, etc). You can use existing images and your brand guidelines to generate the protagonist. 


> [!IMPORTANT]  
> Participants should try to stay away from *Imagen* family of models, these are not well suited for this task. *Gemini Native Image* (aka: *Nano Banana*) is the recommended model.

For the storyboard scene generation again Nano Banana would be the best fit. They can start uploading the relevant protagonist and product pictures together with the text of the their storyboard scene (maybe optimized through Gemini or *Help me write* capabilities) to generate the images.

> [!WARNING]  
> At the time of this writing Nano Banana in Vertex AI Media Studio has a limit of 10MB, so if there are too many images inserted in a single conversation, things will fail. Also there are limits to how many images can be included in a single prompt (3 for Nano Banana at the moment), if the participants go beyond that limit, Nano Banana will silently ignore those. Participants should use multiple conversations and/or fewer images.

These storyboard images will be used in the next challenge and there are multiple ways to reference them. You can use them as start/end frames, you can use them as Subject reference. **If you don’t design your storyboard images with that idea or if you don’t use them in the next challenge, you will struggle with the consistency.**

We also need a **final closing frame** that will inform Veo on how to end the video. It should include space for a Cymbal Pod logo and space for the text of the tagline or call to action (Like buy now or meet your closest Cymbal pod dealer for a test drive etc.).

Finally, **generate a logo** for the Cymbal Pod that conveys the brand.

*We’ve already created a storage bucket for you, make sure that all of this work is stored in that bucket, as we’ll use these assets when we compose our final video (copying those images into your document and screenshotting will negatively impact the quality of these images).*

>### Pro Tips

* The more detailing you have in Challenge \#1 , images would be more consistence  
* Avoid too many things at once. Keep the scene clean. Focus on a good storyline. It can be funny, it can be emotional.  
* Google Models take IP and Safety very seriously. Do not use any known persons, products likeness or names. Safely filter will trigger if Gemini detects such references in the prompt.  
* Have a distinct tagline and Logo.

>### Deliverables

1. Model sheet Image with the protagonist with various angles  
2. Model sheet Image with the product at various angles  
3. 3 story board sheets with \~ 3-4 images depicting the narrative for the scene.  
4. 1 closing frame image with call to action.  
5. 1 Cymbal pod logo (which adheres to brand guidelines) 

>### Success Criteria

- **Multiple consistent images** are generated that clearly define the protagonist’s appearance from various angles.  
- Multiple consistent images are generated that clearly define the Cymbal Pod’s appearance from various angles.  
- You have generated distinct storyboard images and a final closing frame image.  
- The **Cymbal Pod’s design is visibly consistent** across all storyboard images.  
- The **protagonist’s appearance is visibly consistent across** all storyboard images.  
- The **overall aesthetic, mood and color palette is consistent and conforms to your brand guidelines**.  
- Your coach approves of the visual consistency of your images.  
- The images are stored in the storage bucket that has been provided to you.

### Learning Resources

[Vertex AI Studio Quickstart](https://cloud.google.com/vertex-ai/generative-ai/docs/start/quickstarts/quickstart)  
[Nano Banana Prompting Guide](https://developers.googleblog.com/en/how-to-prompt-gemini-2-5-flash-image-generation-for-the-best-results/)  

## Challenge 3: From Stills to Motion

#### Estimated time: 30 mins

### Introduction

With your storyboard and protagonist created, it’s time to bring your vision to life. This challenge is about converting your static scenes into dynamic video clips.

### Description

Using the Veo family of models in Vertex AI Studio, generate video clips for each of your storyboard scenes from Challenge 2\. Make sure you use your generated images as references in your prompts to guide the model. Use the subjects and upload images features to give visual instructions as well as the brand guidelines, narratives etc. to create the prompt. You should absolutely use Gemini to create the right & detailed prompts for you to use.

>### Pro Tips
* In the interest of time and so that everyone gets to play, parallelize this task across your team.
* Video generation is time-intensive. To optimize efficiency, we recommend that **two or three team members simultaneously generate distinct video sets**. Afterwards, compare and select the most effective clips, or regenerate as necessary. Do not delay progress.  
* For enhanced consistency, consider **utilizing a screenshot of the final frame** from Video 1 as the initiating frame for Video 2\.  
* Upload **3-5** images and detailed descriptions.  
* Can’t emphasize enough to go through this guide [Veo on Vertex AI video generation prompt guide](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/video/video-gen-prompt-guide). This separates a great shot from a good shot.  
* Google Models take IP and Safety very seriously. Do not use any known persons, products, films, references, likeness or names. Safely filter will trigger if Gemini detects such references in the prompt.  
* If you see your character develop discrepancies between scenes, like their look changes, go back to Challenge \#2 and develop better images. 
* It’s fine to have background sound or noises for some parts of your video, but keep in mind that you’ll be generating voice-overs in a later challenge. Also, if you need to have dialog that syncs with lips on the screen, that needs to be done during video creation time.
* Once finished, store your favorite clips for each scene in the storage bucket** provided to you (ideally in a separate folder).

>### Deliverable

**4 videos short videos ( 6-8 seconds each):**

1. Start Scene, Middle scene, close scene (3)  
2. Call to action with Logo (1)  
   
>### Success Criteria

- **High-quality** video clips for each of the storyboard scenes are generated.  
- The total runtime for the video clips should be around **\~20-30 seconds combined**  
- The video aesthetics, mood and color palette are **highly consistent** with the corresponding static images.  
- The motion depicted is **smooth and realistic**.  
- When viewed in sequence, the clips form a coherent narrative, with **logical transitions**.  
- Your coach approves of the visual consistency of your videos and their fidelity to your storyboard images.  
- The videos have been stored in the storage bucket that has been provided to you.

### Learning Resources

[Generate videos with Veo](https://cloud.google.com/vertex-ai/docs/generative-ai/video/generate-videos)  
[Veo Prompting Guide](https://cloud.google.com/blog/products/ai-machine-learning/ultimate-prompting-guide-for-veo-3-1)  

## Challenge 4: The Assembly

#### Estimated Time: 20 mins

### Introduction

You have all your visual components. Now it’s time for post-production. In this challenge, you’ll act as the editor, assembling the generated clips into a single, seamless advertisement.

### Description

Using [Google Vids](https://workspace.google.com/products/vids/) stitch together the video clips you created in Challenge 3\. The goal is to create a single, cohesive video file that flows logically and tells the intended story.

To close out the ad, add in the Cymbal Pod logo and any other static graphics you created in Challenge 2\. Don’t forget to add your tagline or call to action here as well.

>###  Pro Tips

* Don't worry about the sound at this step. Just focus on the complete Video. You will add a voiceover in the next step  
* You could use Gemini for generating text as well, but in case you’re not getting what you want, you can just use text elements within your video editor.

> ### Deliverables

* A single 20-30 video that combines all the videos together and tells a consistent story.

>### Success Criteria

- The video is around 20-30 seconds long.  
- The video tells a coherent story, using the shots generated in the previous challenge.  
- The final assembled video is free of jarring cuts, ridiculous transitions (no star wipes\!) or continuity errors.


## Challenge 5: Giving It a Voice

#### Estimated time: 20 mins

### Introduction

A silent film can be powerful, but a voice-over can deliver a targeted message. In this challenge, we’ll generate professional-sounding voice-overs for your ad.

### Description

**First, write a short, compelling script for your ad**. The script should consist of multiple pieces of voice-over audio to be inserted into your ad in different spots. The script should align with the brand guidelines you’ve defined as well as the scenes & narrative of the videos.

### Note

* Once again, using Gemini is expected to generate the script, but you’re also free to use your own writing creativity.  
* Remember the scenes are about 8 seconds long. You could have a different script for each scene with the same voice or a single narrative script for the length of the video.

Next, use the **Chirp 3 HD model in Vertex AI** to generate the voice-overs from your script. 

>### Pro Tips

* This is the final touch of your video. A good narrative is what you need. 
*  You can sample voices and choose the right voice from the samples [here](https://docs.cloud.google.com/text-to-speech/docs/chirp3-hd).  
* If you have already established if it's a male or female voice the choice is easier\!

Finally, add these audio tracks to the video you assembled in Challenge 4 in the proper places in your video sequence timeline. You can use Vids to insert the audio. You can change the speed of the audio in both Vids and in Chirp.

>### Deliverable

* Video with a voice narration.

>###  Success Criteria

- A short, on-brand script is written describing multiple voice-overs as needed in the ad.  
- Multiple high-quality voice-overs are generated.  
- The voice-overs are successfully added to the video file, with timing that matches the visuals.

### Learning Resources

[Prompting tips for Chirp 3 HD](https://docs.cloud.google.com/text-to-speech/docs/chirp3-hd#scripting-and-prompting-tips)  
[Prompting tips for Gemini Text to Speech](https://docs.cloud.google.com/text-to-speech/docs/gemini-tts#prompting_tips)

## Challenge 6: The Soundtrack

#### Estimated time: 15 mins

### Introduction

Music is an important layer of emotion in your ad. To complete your masterpiece, you will use Google’s Lyria model to compose a custom piece of background music that complements the visuals and voice-over.

### Description

Using the **Lyria** model in Vertex AI, generate a music track for the entire ad. Remember to adhere to your brand guidelines.

Once you have a track you’re happy with, add it as a final audio layer to your video sequence timeline. **Make sure to balance the volume** so that the music complements the voice-overs without overpowering them.

>### Pro Tips

* *Keep in mind that Gemini itself can be a helping hand here. If you give it your brand guidelines and/or your video, it can give you a recommendation for a good soundtrack to use.*  
* *The Lyria model is trained from the point of view of a musician and their instrument. You’ll get better results if your prompt speaks in the language of instruments.*

>### Deliverable

* Video with narration and background music.

>### Success Criteria

- A music track is generated for the entire length of the ad.  
- The music’s mood and style align with the brand guidelines.  
- The music is successfully added to the video, creating a final, polished ad with visuals, voice-over, and a soundtrack.  
- You’ve exported your final ad as an MP4 file.

