# Easy Ads: From Concept to Creation with GenMedia

## Introduction

Welcome to the coach's guide for the *Easy Ads: From Concept to Creation with GenMedia* gHack. Here you will find links to specific guidance for coaches for each of the challenges.

> [!NOTE]  
> If you are a gHacks participant, this is the answer guide. Don't cheat yourself by looking at this guide during the hack!

## Coach's Guides

## Challenges

- Challenge 1: From Product to Narrative  
- Challenge 2: The Visual Blueprint  
- Challenge 3: From Stills to Motion  
- Challenge 4: The Assembly  
- Challenge 5: Giving It a Voice  
- Challenge 6: The Soundtrack  

## Challenge 1: From Product to Narrative

### Notes & Guidance

If the participants are using Vertex AI Studio for generating the story, they should turn on auto-save. This way they can keep track of their progress and easily hand over the generated descriptions to the next driver.

It is helpful to have generic system instructions when using Gemini, although there would be great variety, something like that captures what we expect (the purpose and the subject):

```text
We're creating an ad for a product called The Cymbal Pod which is a single person, urban transport vehicle that hovers silently and moves quietly through the world.
```

Although it's hard to assess the quality of the deliverables, these should be consistent, coherent, on-brand and brief.

We're expecting *at least* three scenes, but it makes sense to have more (and shorter) scenes. Veo will struggle if there's too much happening in a single scene. The snippet below is from *Veo Prompting Best Practices*:

> Attempting to prompt "A knight battles a dragon, then flies on its back to a castle, then attends a feast" in a single prompt for an 8-second clip will likely result in a muddled or incomplete depiction of one small part, or a very rushed and incoherent sequence. Instead, generate each distinct part as a separate clip if needed

## Challenge 2: The Visual Blueprint

### Notes & Guidance

The idea is that the participants should use the descriptions from Challenge 1, and use either Gemini or *Help me write* capabilities with Vertex AI Media Studio to generate the required prompts. They should start using *Imagen* for the original images for the protagonist and the product, and then switch to Nano Banana to generate the different angles.

For the storyboard scene generation again Nano Banana would be the best fit. They can start uploading the relevant protagonist and product pictures together with the text of the their storyboard scene (maybe optimized through Gemini or *Help me write* capabilities) to generate the images.

> [!NOTE]  
> If participants choose to generate the different angles or the storyboard scenes with Imagen, this could be quite hard for consistency. Let them experiment to find out how hard that is but **DO NOT** let them spend too much time on that approach.

> [!WARNING]  
> At the time of this writing Nano Banana in Vertex AI Media Studio has a limit of 10MB, so if there are too many images inserted in a single conversation, things will fail. Participants should use multiple conversations and/or fewer images.

## Challenge 3: From Stills to Motion

### Notes & Guidance

The storyboard images created in the previous challenge should be used as a *Reference* to generate the video clips. If the participants gloss over this, they will struggle with consistency. Similarly, just like the previous challenge, **DO NOT** let them struggle for too long.

> [!NOTE]  
> At the time of this writing only Veo 2 can do references, so it's okay if participants use that model.

## Challenge 4: The Assembly

### Notes & Guidance

#### Video Editor

In the rest of this gHack's challenges, you will be piecing together your final ad video. Unless you prefer your own editing tools (Adobe Premiere Pro, Final Cut Pro, DaVinci Resolve, etc), we strongly recommend using Google Vids.

Google Vids is a web-based video creation app designed to make producing professional videos as simple as creating a slide deck without any prior video editing experience. It is available on any Google Workspace account and also on personal gmail accounts if necessary.

## Challenge 5: Giving It a Voice

### Notes & Guidance

You'll have the choice to use Google's Chirp model or Gemini itself to create the voice-overs. The difference between these two lies in the source of vocal identity and style. Chirp functions as an advanced text-to-speech engine, requiring a pre-existing voice, either from its library or a custom clone, to articulate the provided text with high fidelity; any stylistic nuance is primarily achieved through manipulating the text itself with punctuation and pacing adjustments. In contrast, Gemini operates as a true generative voice model, creating the vocal characteristics and delivery style from scratch based on natural language prompts. This allows a user to conjure a voice by describing it (e.g., "a deep, soothing voice") and directing its emotional tone (e.g., "speak with excitement"), offering a layer of creative control and on-the-fly vocal design that Chirp, in this context, does not.

## Challenge 6: The Soundtrack

### Notes & Guidance

Including instrument information in the prompt can be helpful.
