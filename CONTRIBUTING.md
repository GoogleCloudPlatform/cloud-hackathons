# gHacks - Contribution Guide

gHacks are all about being "for the people, by the people". This repo was originally created to share real-world hackathons that Google Cloud teams have hosted with their customers. It has since grown to be a learning tool for anyone, anywhere, and follows these core principles:

- Anyone can use the content to [host their own gHacks event](./faq/howto-host-hack.md).
- Anyone can [contribute a new hack](#contribute-a-new-hack-to-what-the-hack).
- Anyone can modify or update a hack as needed.
  - Submitting a [pull request for updated content](#contribute-an-update-to-an-existing-hack) is encouraged.
- The content can always be shared with hack attendees **(AFTER your event)**.

This document provides the general guidelines for how to contribute to the gHacks project.

## How Can I Contribute?

The best way to contribute is to engage the gHacks team by [submitting an issue via GitHub](https://github.com/gfilicetti/gHacks/issues/new/choose). 

There are multiple ways to contribute:

- [Report a bug in an existing hack](#report-a-bug-in-an-existing-hack)
- [Propose new hack topic or improvement to existing hack](#propose-new-hack-topic-or-improvement-to-existing-hack)
- [Contribute a new hack](#contribute-a-new-hack-to-what-the-hack)
- [Contribute an update to an existing hack](#contribute-an-update-to-an-existing-hack)
- [Ask for help hosting a gHacks event](#ask-for-help-hosting-a-what-the-hack)
- [Let us know where you have used gHacks](#let-us-know-where-you-have-used-what-the-hack)

### Before You Start

Before you start contributing and file an issue, make sure you've checked for existing issues:
   - Before you create a new issue, please do a search in [open issues](https://github.com/gfilicetti/gHacks/issues) to see if the issue or feature request has already been filed.
   - If you find your issue already exists, make relevant comments and add your [reaction](https://github.com/blog/2119-add-reaction-to-pull-requests-issues-and-comments). Use a reaction:
        - 👍 up-vote
        - 👎 down-vote

## Report a Bug in an Existing Hack

You have found a bug in a hack and want to report it. Great! Something is not right, and it needs to be fixed. 

Please go to the Issues page for the gHacks repo and create an [Issue/Bug](https://github.com/gfilicetti/gHacks/issues/new?assignees=&labels=bug&template=bug.yml&title=%5BBug%5D%3A+). 

Let us know which hack has the bug. Is it in the Student guide? Coach guide? Is it a documentation issue? Or an issue with a provided resource file or solution file? The form will guide you on what information you should submit. The gHacks team will follow up on your submission. 

We welcome bug fixes!  If you wish fix the bug yourself, please see the section on how to [Contribute an update to an existing hack](#contribute-an-update-to-an-existing-hack)

## Propose a New Hack or an Improvement to an Existing Hack

You have a proposal on how to improve an existing hack, or you want to suggest a new hack topic. For improving an existing hack, your proposal should go beyond a "bug fix" and be a fair sized improvement or addition of content.

For new hack proposals, consider:
   - Is this a net new hack topic? Or should your contribution extend or modify an existing hack?
   - It is okay to have more than one hack on the same technology, but the new hack should be an independent set of challenges that stand on their own.

At this point, you are just giving feedback.  You may, or may not, be interested in authoring or updating content yourself. Thanks in advance for your feedback, we can't wait to read it!

Please go to the Issues page for the gHacks repo and create an [Issue/Proposal](https://github.com/gfilicetti/gHacks/issues/new?assignees=&labels=proposal&template=proposal.yml&title=%5BProposal%5D%3A+). 

The form will guide you on what information you should submit. The gHacks team will follow up on your proposal. 

We welcome new hacks and improvements to existing hacks. If you intend to 'do the work' you are proposing, read on for how to:
- [Contribute a new hack to gHacks](#contribute-a-new-hack-to-what-the-hack)
OR
- [Contribute an update to an existing hack](#contribute-an-update-to-an-existing-hack)

## Contribute a New Hack to gHacks

You want to author a new hack yourself, or with a team of others, and contribute it to gHacks. 

Please check if there is an existing "Proposal" Issue in the gHacks repo to track your new hack. Add a comment to the existing issue to let the gHacks team know you are working on this contribution.

If there is no existing Issue for the new hack you plan to contribute, please start by going to the Issues page for the gHacks repo and create an [Issue/Proposal](https://github.com/gfilicetti/gHacks/issues/new?assignees=&labels=proposal&template=proposal.yml&title=%5BProposal%5D%3A+).

In general, the gHacks team prefers to collaborate with and assist contributors as they author new hacks. This makes the review process smoother when a new hack is ready to be published via a Pull Request. 

By collaborating with the gHacks team from the start, it sets your hack up for success by reducing:
- Any conflicts with other hacks under development
- Potential re-work from not following our process and required template formats
- The time to publish your hack to the public

### On-Boarding Process (Optional, but STRONGLY recommended)

Once you have submitted an [Issue/Proposal](https://github.com/gfilicetti/gHacks/issues/new?labels=proposal&template=proposal.yml&title=%5BProposal%5D%3A+) via GitHub, you can expect the following:

1.	The gHacks team will get in touch to start the on-boarding process. If they are aware of other authors with similar proposals, they will schedule a meeting with everyone to see if it makes sense to combine efforts.
1.	The gHacks team will schedule a kick off call with you and any co-authors to:
    - Review the gHacks contribution process and set expectations for collaboration between the gHacks team and the author(s).
    - Walk through the [gHacks Author's Guide](./faq/howto-author-hack.md). 
        - All authors need to read and internalize this document to save you trouble and heartache down the line.
    - Set up a bi-weekly cadence meeting to check-in and address any questions or requests you have during development.
1.	During the cadence meetings, the authors will dictate the pace of the call and report what they have worked on. It is essentially your time to discuss things with the gHacks team and/or collaborate with your co-authors. If there is a stint that nothing was worked on, that’s totally fine. We understand and appreciate that most folks are contributing to gHacks in their spare time.

**NOTE:** If you are not familiar with Git, GitHub, or Markdown files, you are not alone! Since gHacks is a collection of mostly course content and documentation, many of our contributors are not developers. It's out of scope to explain these tools here. However, there are plenty of great resources on the Internet that can help get you up to speed. Here are two to consider as starters:
- [Contributing to projects on GitHub](https://docs.github.com/en/get-started/quickstart/contributing-to-projects)
- [Basic writing and formatting syntax (for GitHub Flavored Markdown)](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax)

Also, don't be shy to ask the gHacks team for help navigating Git and GitHub. 

### Development Process

All contributions to the gHacks repo come through pull requests. This means that development of a hack starts by forking the gHacks repo into your own GitHub account. This is where you will do your work. Eventually, you will create a pull request to submit your work back to the gHacks repo for review.

**NOTE:** If you are working with a team of co-authors, the team should pick one person to create a fork into their GitHub account. The other authors should collaborate and contribute to that person's fork during the development process.

Okay, ready to get started creating your own gHack?

The instructions below assume you have the [Git command line tool](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) on your machine. If you're more comfortable in a GUI Git client, you can use that too (we recommend [Atlassian's SourceTree](https://www.sourcetreeapp.com/)).

1. Create a fork of the gHacks repo
   - Navigate to the gHacks repo at: <https://github.com/gfilicetti/gHacks>
   - Click the "Fork" button at the top right of the page and then choose the account you want to create the fork in. 
1. Clone your new fork to your local machine
   ```
   git clone https://github.com/<myname>/WhatTheHack.git
   cd WhatTheHack
   ```
1. Create a new branch for your work in your fork. It is a best practice to never work directly on the main/master branch
   ```
   git branch MyWork
   git checkout MyWork
   ```
1. Add a new folder to the 'hacks' top level folder in the gHacks repo using "snake-case" `mkdir hacks iot-in-manufacturing`
1. Within your new folder, create the following directory structure:
	```
    ../coach
	    /assets - for files to help coaches with the solution
	../student
	    /assets - for initial files students will build from
    ```
1. Follow the [gHacks Author's Guide](./faq/howto-author-hack.md) and scaffold out your hack's content as shown here:
    - `../`
        - Hack Description
    - `../coach`
        - The Coach's Guide, Lecture presentations, and any supporting files.
        - `/assets`
            - Solution code for the coach only. These are the answers and should not be shared with students.
    - `../student`
        - The Student guide's Challenge markdown files
        - `/assets` 
            - The code and supporting files the students will need throughout the hack.
1. Re-read the [gHacks Author's Guide](./faq/howto-author-hack.md) (seriously) and make sure your hack follows the templates & styles for consistency.

### Release Process

When you feel your hack is finished and ready for release, this is the process we will follow:

1.	The gHacks team will schedule a 60-minute "pre-PR review" meeting with you and any co-authors. 
    - The purpose of this meeting is to go through the content together and reduce the amount of back and forth review cycles on GitHub once your Pull Request is submitted.
    - During this review, the gHacks team will go through the text with a fine-toothed comb checking for:
        - Adherence to the [gHacks Author's Guide](./faq/howto-author-hack.md)
        - All links work, especially the navigation links
        - There are no links to the gHacks repo or Coach's guide from the Student guide (See the [gHacks Author's Guide](./faq/howto-author-hack.md))
        - All images show properly.
        - Any syntax, grammar or punctuation problems that the reviewers see and want you to address.
        - This is NOT a technical content review. As the author(s), YOU are the subject matter experts. The gHacks team will trust that you have taken care of the technical bits.
    - **NOTE:** It is important that you take notes through-out the meeting so that you can go away, make any changes requested, and not miss anything.
1.	Once you have completed any requested changes from the "pre-PR review":
    1. [Fetch the latest updates from the upstream repository](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/syncing-a-fork) (to merge any changes others have made to gHacks while you were working on your hack) and ensure there are no conflicts with your hack's content. 
    2. [Create a pull request from your fork](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request-from-a-fork) to submit your work back to the gHacks repo for review.
1.	The gHacks team will review your PR and leave comments if there are any requested changes that still remain. If there are requested changes, please add further comments if you have clarifying questions to ask, or arguments against, the requested changes (that’s ok).
    - **NOTE:** Make any requested changes by continuing to commit to your fork. The PR will automatically update with your changes.  You do NOT need to create a new pull request!
1.	Once you have addressed any requested changes from the gHacks team, the gHacks team will accept and merge the PR.

## Contribute an Update to an Existing Hack

If you are planning to fix a bug or implement an update for an existing hack, please check if there is an existing Issue agains the gHacks repo to track it. Add a comment to the existing issue to let the gHacks team know you are working on this contribution.

If there is no existing Issue for the update you plan to contribute, please start by going to the Issues page for the gHacks repo and create one:
 - For bug fixes: ["Issue/Bug"](https://github.com/gfilicetti/gHacks/issues/new?assignees=&labels=bug&template=bug.yml&title=%5BBug%5D%3A+). 
- For general improvements: ["Issue/Proposal"](https://github.com/gfilicetti/gHacks/issues/new?assignees=&labels=proposal&template=proposal.yml&title=%5BProposal%5D%3A+).

To contribute an update to an existing hack, you should:
1. Fork the gHacks repo into your own GitHub account. 
1. Create a new branch in your fork. This is where you will do your work. (**NOTE:** It is a best practice to never work directly on the main/master branch so that it always reflects the state of the upstream main gHacks repo.) 
1. When you have completed the update in your fork:
    1. [Fetch the latest updates from the upstream repository](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/syncing-a-fork) (to merge any changes others have made to gHacks while you were working on your update) and ensure there are no conflicts with your updates. 
    2. [Create a pull request from your fork](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request-from-a-fork) to submit your work back to the gHacks repo for review.

The gHacks team will review the Pull Request with an eye towards compliance with the [gHacks Author's Guide](./_FAQ/gH-HowToAuthorAHack.md), as well as any spelling or grammar issues. These reviews are generally shorter if the update is by one of the hack's original authors.  

If the update is from a new contributor, the gHacks team will request one of the original author's of the hack to review the update for technical accuracy.

## Ask for Help Hosting a gHacks Event

We've put together a lot of guidance on how to host a gHacks event in our [gHacks Hosting Guide](./faq/howto-host-hack.md).  

If you have further questions, or want to get in touch with the gHacks team to learn more about hosting a gHacks event, please go to the Issues page for the gHacks repo and create an [Issue/Request](https://github.com/gfilicetti/gHacks/issues/new?assignees=&labels=request&template=request.yml&title=%5BRequest%5D%3A+).

**NOTE:** The gHacks repo is self-serve content. The gHacks team does not offer logistical support or GCP environments. The gHacks team will make its best effort to connect you with hack authors for details on the technical content, or answer any other questions you have about hosting an event.

## Let Us Know Where You Have Used gHacks

The BEST feedback you could share is to let us know how and where you have used gHacks content. Our hacks' authors are always excited to learn if their content is being used. We would love to know delivery dates, # of attendees, locations (if in-person), and how it impacted your attendees' technical readiness.

If you have found this content useful, or hosted a gHacks event, please go to the Issues page for the gHacks repo and create an [Issue/Report](https://github.com/gfilicetti/gHacks/issues/new?assignees=&labels=report&template=report.yml&title=%5BReport%5D%3A+).

**NOTE: Reporting that you hosted a gHacks event this way will be publicly viewable. You should NOT share the name of the organization you hosted an event with unless the organization has given permission to share its name publicly.**

## Thank You!
 Your contributions to open source, large or small, make projects like this possible. Thank you for taking the time to contribute.