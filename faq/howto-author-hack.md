# gHacks - How to Author a gHack

Developing a new gHack is a great way to get your content out to the world. Chances are if you've done workshops, PoCs or pilots in the past, you already have the material on which to build a gHack.

## Why gHack?

The gHack "challenge" format is perfect for a team-based, hands-on learning experience.

gHacks are all about being "for the people, by the people". Here are our core principles:
- Anyone can contribute a gHack.
- Anyone can use gHacks content to host their own event.
- Anyone can modify the content as needed.
  - Submitting a pull request for modified/improved content is encouraged.
- The content can be shared with attendees AFTER the event for continuity purposes.

## What Does It Take To Create a gHack?

When you design a gHack, these are the things you should consider:

- [Student Guide](#student-guide)
- [Challenge Design](#challenge-design)
- [Student Resources](#student-resources)
- [Presentation Lectures](#presentation-lectures) (optional)
- [Coach's Guide](#coaches-guide)
- [Coach Solutions](#coach-solutions)

If you create things in this order, you will be able to quickly flesh out a new hack. 

> **Note** The Coach's guide is the most detail oriented & time consuming item to produce however, there's a pro tip: Hack authors have been known to write the Coach's Guide as a post-mortem from their first run of the hack.

## Student Guide

Why should someone take the time to deliver or participate in your hack?  This is the main question you need to answer in order to define your hack. Every gHack needs to have a good executive summary that quickly describes your hack to those who will host or attend your hack. Think of this as your marketing pitch. 

The **Student Guide** is the README.md that lives in the root of your hack's top level folder.

The **Student Guide** must include the following:

### Hack Title

Give your hack name. Keep it short, but consider giving it a "fun" name that is more than just the name of the technologies the hack will cover.
  
### Introduction

This is your chance to sell the casual reader on why they should consider your hack. In a paragraph or two, consider answering the following questions:

- What technologies or solutions will it cover? 
- Why are these technologies or solutions important or relevant to the industry?
- What real world scenarios can these technologies or solutions be applied to?

### Learning Objectives

This is where you describe the outcomes a hack attendee should have. Provide a short list of key learnings you expect someone to come away with when they complete this hack.

### Challenges - Table of Contents

Every gHack is made up of a collection of technical challenges. Here we list out the challenges by name, with no more than a single sentence description for each unless the challenge title is descriptive enough on its own.

Because this is a table of contents, we recommend that you create links to the challenge text further down in the Student Guide.

### Prerequisites

Provide a list of technical prerequisites for your hack here.  List out assumed knowledge attendees should have to be successful with the hack. For example, if the hack is an "Introduction to Kubernetes", the attendee should have a basic understanding of containers.  However, if it is an "Advanced Kubernetes" hack, then the attendee should know the basics of Kubernetes and not ask you what a "pod" or "deployment" is.

Provide a list of tools/software that the attendee needs to install on their machine to complete the hack. 

### Contributors

Finally, give yourself and your fellow hack authors some credit. List the names and optionally contact info for all of the authors that have contributed to this hack.

### Student Guide Template

To help you get started, we have provided a sample template for the Student Guide here:
- [Student Guide Template](template-student-guide.md). 

Please copy this template into your hack's root folder, rename it to **README.md**, and customize it for your hack.

## Challenge Design

Challenges are at the heart of the gHack format. Designing challenges is what a hack author should spend the majority of their time focusing on. 

There are different approaches to designing a hackathon. If you are familiar with the Marvel Comic Universe movies, you know that they follow one of two patterns:
- "Origin Story" - A movie focused on the back story of a SINGLE superhero that lets the audience get to know that character in depth (perhaps with a sidekick character or two included).
- "Avengers Story" - A movie with an ensemble cast of superhero characters working together to solve a mega problem, with each character getting varying amounts of screen time. 

You can use the same patterns when designing a gHack.

- Singleton Hack - A hack designed to give in-depth hands-on experience with a specific technology and maybe a "sidekick technology" or two included.
- Solution Hack - A hack designed to give experience solving a real-world scenario that involves using multiple technologies together for the solution.

Once you have decided what type of hack you want to create, you should follow these guidelines when designing the challenges:

- Include a “Challenge 0” that helps attendees install all of the prerequisites that are required on their computer, virtual environment or GCP account.
- Challenge descriptions should be shorter than this section on how to design challenges. Keep it to a couple of sentences or bullet points stating the goal(s) and perhaps a hint at the skill(s) needed.
- Think through what skills/experience you want attendees to walk away with by completing each challenge
- Challenges should be cumulative, building upon each other and they should:
    - Establish Confidence – Start small and simple (think "Hello World")
    - Build Competence – By having successively more complex challenges.	
- Each challenge should provide educational value.  
    - For example, if an attendee completes only 3 out of 7 challenges, they should still walk away feeling satisfied that they have learned something valuable.
- Take into consideration that a challenge might have more than one way to solve it and that's OK.
- Provide verifiable success criteria for each challenge that lets the coaches and attendees know they have completed it.
- Provide relevant links to learning resources that should lead the attendees toward the knowledge they need to complete the challenge.
- Provide hints for items that could potentially be time consuming to figure out but are of low learning value or relevance to the actual goal of the challenge. **EG:** A command line parameter that is not obvious but would take hours to debug if it were missed.
- Do **NOT** provide a list of step-by-step instructions. These are challenges designed to make the attendees learn by solving problems, not blindly following instructions.

### Challenge Template

To help you get started, we have provided a sample markdown template for an individual gHack Challenge in the [Student Guide Template](template-student-guide.md).

If you haven't already, please copy this template into your hack's root folder and rename it to `README.md`.

For each of your challenges, you will add to the end of your Student Guide a new copy of the challenge template markdown that starts with: 
```markdown
## Challenge <#>: <Challenge Name>
```

Keep in mind that we're using [Github Flavored Markdown](https://github.github.com/gfm/) and support highlighting of blockquotes that start with `> **Note**` or `> **Warning**`. In addition any line that ends with two spaces and a newline will cause renderer to emit a linebreak. 

## Student Resources

It is common to provide attendees with resources in order to complete the hack's challenges.  One example is to provide the code for an application that the hack's challenges are based on. Another example might be to provide sample or starter code files, artifacts, or templates that provide guidance for completing the hack's challenges.

If your hack provides attendees with code or resources, they should be included with your hack's contents in the `resources` folder.

During a gHack event, it is recommended that you have attendees download any provided resources as a zip file instead of having them clone the entire gHack repo onto their computer. Part of the [How To Host a gHack](howto-host-hack.md) guide gives instructions on how to make material available before your event.

This has the benefit of not having to direct the attendees to the gHack repo during your hack. Remember, attendees can always find the gHack repo.  However, remind your attendees that they are cheating themselves out of an education if they go foraging around in the gHack repo for the answers.

## Presentation Lectures

You may be wondering why there is a section called "Presentation Lectures" when the whole point of gHack is to be hands-on and not eyes front?

When you host a gHack event, there is always a kick off meeting where the attendees are welcomed and then introduced to the logistics of the hack. The best way to do that is with a *short* presentation delivered a few slides at a time.

After the kickoff meeting, its up to the hack authors if they want to provide any presentation lectures.  Some hack challenges are easy to jump right into.  Others are more complex and are better preceded by a brief introduction presentation.

It is OK and encouraged to offer a collection of "mini" presentation lectures if necessary for your hack's challenges. If you do provide a presentation lecture, consider these guidelines for each challenge:

- Try to limit the lectures to **5-10 minutes** per challenge.
- Provide a brief overview of the challenge scenario & success criteria
- Provide a brief overview of concepts needed to complete the challenge
- Provide "reference" slides that you might not present, but will have on hand if attendees need additional guidance
- Provide a slide with the challenge description that can be displayed when attendees are working on that challenge

We have more guidance on how and when to deliver mini presentation lectures for your challenges during your event in the [How To Host a gHack](howto-host-hack.md) guide.

Please publish any presentations in your hack's `resources` folder as a PDF file.

## Coach's Guide

Every gHack should come with a Coach's guide. The simple way to think of the Coach's guide is that should be the document with all of "the answers". The reality is, doing so would turn it into a giant step-by-step document loaded with detailed commands, screenshots, and other resources that are certain to be obsolete the minute you publish it. No one wants to maintain a document like that. 

Instead of treating the Coach's guide like a step-by-step document, treat it as the "owner's manual" you would want to provide to future coaches so they can host and deliver your gHack to others. 

The Coach's guide should include the following:

- List of high-level solution steps to each challenge
- List of known blockers (things attendees will get hung up on) and recommended hints for solving them. For example:
    - Resources that will take a long time to deploy in GCP: Go get a coffee.
    - Permission issues to be aware of, etc
- List of key concepts that should be explained to/understood by attendees before a given challenge (perhaps with a presentation lecture)
- List of reference links/articles/documentation that can be shared if attendees get stuck
- Estimated time it would take an attendee to complete each challenge. This will help coaches track progress against expectation. It should NOT to be shared with attendees.
- Suggested time a coach should wait before helping out if a team is not progressing past known blockers

The Coach's guide should be updated during & post event with key learnings, such as all the gotchas, snags, and other unexpected blockers that your attendees hit.

## Coach Solutions

This is where you put "the answers". There are usually multiple ways to solve a gHack Challenge. The solutions you provide here should be example solutions that represent one way to solve the challenges. The solution resources might include a full working application, configuration files, populated templates, or other resources that can be used to demonstrate how to solve the challenges. 

Examples of Coach Solutions are:
- Prerequisites for the GCP environment if needed. 
    - Example: A VM image with Visual Studio or ML tools pre-installed. 
    - Example: A Terraform template and/or script that builds out an environment that saves time on solving a challenge
- Scripts/templates/etc for some challenges that can be shared with attendees if they get really stuck
    - Example: If challenges 1 through 3 build something (i.e. a GKE cluster) that is needed for challenge 4, you could “give” a stuck team the scripts so they could skip to challenge 4.

> **Note**  
> This content is NOT intended for hack attendees to see before or during a hack event. The content IS available publicly and thus an attendee can and WILL find it if they are determined enough. It is important to stress to the attendees that they should not cheat themselves out of an education by looking at the solutions.

### Solution Template

To help you get started, we have provided a sample markdown template for a Coach's Guide in the [Coach's Guide Template](template-coach-guide.md).

Please copy this template into your hack's top folder, rename it to `solutions.md`, customize it and add in all of your challenges.

## Preparing Your Environment

Okay, ready to get started creating your own gHack?

First we create a fork of the main gHack repo and then clone it to disk and create a branch to work in. The instructions below assume you have the git command line on your machine. If you're more comfortable in a GUI git client, you can use that too (we recommend SourceTree).
1. Create a fork of the gHack repo
   - Navigate to the gHack git repo at: <http://github.com/gfilicetti/gHacks>
   - Click the Fork button at the top right of the page and then choose the account you want to create the fork in. 
2. Clone your new fork to your local machine
   - `git clone https://github.com/myname/gHacks.git`
   - `cd gHacks`
3. Create a new branch for your work. It is a best practice to never work directly on the main branch
   - `git checkout -b my-branch`
4. Add a new folder to the top-level `hacks` root folder. Name your hack something distinctive using snake-case. Eg:
   - `mkdir hacks/century-of-iot`
5. Within your new folder, you'll need at least two files `README.md` and `solutions.md`. If you have additional assets such as images for the descriptions, you can put those in an `images` folder. If you choose to associate a Qwiklabs lab with the hack, you'll need to provide a `QL_OWNER` file (which includes the email addresses of the lab owners), a `qwiklabs.yaml` file (which configures the lab and its resources). Additionally if you need to do any setup for the lab you can use Terraform scripts for that which need to be in the `artifacts` directory accompanied by a `runtime.yaml`.   

### Files and Folders

Now that you've created the directory structure above, here is what each of them will contain:

```
hacks
├── century-of-iot
│   ├── artifacts  # (Optional) Terraform setup for Qwiklabs
│   │   ├── main.tf
│   │   ├── runtime.yaml
│   │   └── variables.tf
│   ├── images  # (Optional) Images used for hack description and/or solutions 
│   │   ├── architecture.png
│   │   └── results.png
│   ├── resources # (Optional) Lecture presentations, supporting files, etc. Will be supplied to students
│   │   ├── lectures.pdf
│   │   ├── kube-deploy.yaml
│   │   └── testing.html
│   ├── README.md      # (Required) Hack description
│   ├── solutions.md   # (Required) The coach's guide
│   ├── QL_OWNER       # (Required for qwiklabs) Line separated list of owner & collaborator's emails for the Qwiklab
│   └── qwiklabs.yaml  # (Required for qwiklabs) Qwiklab configuration
└── ...
```
