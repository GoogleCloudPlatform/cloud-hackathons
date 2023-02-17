# gHacks - How to Host a gHack

In a post-covid world, virtual events will be the way of the future for some time. Participating in a team-based hands-on event virtually may be a new concept for many. However, we have found that virtual gHacks events are often more collaborative than a traditional in-person event.

This document has the following sections:
- [gHacks Event Requirements](#what-do-you-need-to-host-a-ghacks-event)
- [gHacks Event Preparation](#event-preparation)
- [gHacks Event Day](#event-day)


## What do you need to host a gHacks event?

At a minimum, three things:
1. [Hack Content](#hack-content)
1. [Google Chat and Meet](#google-chat-and-meet)
1. [People](#people)

### Hack Content

First and most important is hack content. The gHacks collection has many different hacks that have been contributed. 

Choose a hack from the [gHacks Collection](../README.md#the-ghacks-collection)

Or, create your own with the guidance we have on [How To Author gHacks](howto-author-hack.md)

### Google Chat and Meet

Next, you need Google Chat and Google Meet. Specifically, we'll be creating a Google Chat Space that will be dedicated for your particular event. In this Space we'll be able to share files with the attendees, chat together and we'll host a single Google Meet for all participants which will have breakout rooms for each team. 

During a gHacks event, attendees work together in squads of 3 to 5 people to solve the hack's challenges. The attendees will need to share links, code snippets, or even screen share as they collaborate on the challenge solutions. 

At an in-person event, each squad will be sitting at the same table. During a virtual event, everyone will be sitting at home in their pajamas. The main difference is that during a virtual event, attendees will need to join the Meet call in the event's Chat Space for the duration of the event. Most other aspects of the event are the same.

### People 

Finally, you need people to hack. There are a few different roles that will need to be played at your gHacks event. They include:
- Lead Coach
	- The lead of the event both logistically and technically. 
	- Responsible for the event preparation steps [outlined below](#event-preparation).
	- This person should be intimately familiar with the content and all of its solutions.
	- Delivers kick off meeting & challenge intro lecture presentations (if required)
- Coaches
	- The personal coach/facilitator/TA for a squad of 3 to 5 attendees.
    	- It is recommended to have 1 coach for every 5 attendees. At a minimum, there should be 1 coach for every 10 attendees.
	- Provides guidance and direction for the squad but does **NOT** provide answers. Typically answering questions with more questions and things to "ponder".
	- In charge of determining whether a squad has finished a challenge based on the acceptance criteria in the challenge text. This review will determine if they move on to the next challenge.
- Attendees
	- The students in the event that participate in squads of 3 to 5.
	- Must join and participate in the event's Google Meet AND have their webcam and microphone turned on at all times. This most accurately simulates an in person team environment.

## Event Preparation

If you've gotten this far, then you have designated yourself as "Lead Coach" and are preparing to host a gHacks event.

As the event leader, most of the preparation steps are focused on preparing the collaboration tools: Google Chat, Spaces, Meet, etc. The preparation checklist focuses on three key areas:

- [Know Your Audience](#know-your-audience)
- [Google Space Creation](#google-space-creation)
- [Getting People To Your Event](#getting-people-to-your-event)

### Know Your Audience

If you are inviting attendees that are outside of your organization, there are multiple things to think about with respect to using the hack environment and collaboration tools.

If you are hosting a hack with a single organization, it is critical to identify an event stakeholder in the external organization who can help you plan for your gHacks event. The event stakeholder can help you address the following preparation concerns. **NOTE:** It is recommended that you start planning at least 2 weeks before the event to make sure everything is ironed out.

#### GCP Subscription
Most of the hacks in the gHacks collection require attendees to have "Contributor" access to a GCP project. 

It is important to work with the event stakeholder to decide how attendees will access GCP. Some organizations may provide individuals with their own projects.  Other organizations may provide access to a shared project created specifically for attendees to use during the hack event. 

If the organization is not providing access to a GCP project for the hack, attendees will need to provide there own or a QwikLabs environment if the hack has created one.

#### Workstation Security

Some organizations have tight security policies enforced on their employees' workstations. A common one is to not provide users with administrator privileges on their workstation. If this is the case, it may prevent them from installing tools or software needed to complete the hack.  

One workaround is to use the Google Cloud Shell. However, some organizations may disable access to the Google Cloud Shell.  Another workaround is to provision a workstation VM in GCP that attendees can SSH into to complete the hack.

Tight firewalls may make it challenging to access even the GCP Console itself from an organization's workstations. This is when you bang your head against the wall, give up, and be thankful you don't work for that organization! :)

All of these security concerns and their mitigation should be identified and addressed with the organization event stakeholder ahead of time.

### Google Space Creation

Now that you've gotten all of the overhead out of the way, it's time to build your event's Google Space.

This new Google Space will be used as the dedicated event space. This space will host documents, the Google Meet for the event along with its break-out rooms for each team and overall collaboration in real and near real-time.

We suggest naming your Google Space with at minimum the hack name and organization. You can also add the location or date too. This will make it easy for attendees to remember what the Space was for after the event.

For example: `"gHack - Acme - Security in Media"`

#### Space Structure
----------------- NEED SCREENSHOTS FOR EACH BULLET ----------

In our Google Space, we will have the following:

- **Student Guide** - The lead coach will paste a link to the student guide as the first entry in the chat.
- **Files** - The lead coach will upload all files from the `resources` folder to make them available to the students. Also if there is a Lectures PDF or other needed files they should go here.
- **Google Meet** - The lead coach will kick off by creating a new Google Meet in the space. This will be the central gathering spot for all the attendees. This is where the kick off session, lectures, Q&A and the wrap up sessions are held together with all attendees and coaches.
- **Breakout Room** - The lead coach will create 1 breakout room per team in the hack and name it appropriately. The students will then join the breakout room they were assigned to work with their team. Coaches will join the breakout room for the team they were assigned. The lead coach will float around each of the breakout rooms as needed.
- **Coaches ONLY Chat** - The lead coach will create a multi-person chat for all the coaches to discuss things in private, away from student eyes.

### Getting People To Your Event

Now that you have taken care of creating and preparing a Google Space for your hack, you need to get people to your hack.

#### Registration and Invites

It is up to you to decide how you will advertise your hack. You might send an invite to a larger group and let those interested RSVP by registering. Using [Google Forms](https://forms.google.com) is a great way to manage your event registration. **NOTE:** Be sure you understand the privacy implications of gathering personal information in a Google Form.

If you are hosting an hack for an external organization, you should coordinate with the event stakeholder to determine how attendees will be invited. It is often best to let the event stakeholder manage the invite and registration process. That's one less job for you.

#### Add Registered Attendees To Google Space

If you are hosting a virtual event, the event location <u>***IS***</u> the event Space you created in Google Chat. Therefore, it is important that the attendees be added to the Space <u>***before***</u> the event.

Whether you used a Google Form or worked with an external organization stakeholder, you should gather the list of registered attendees and add them to the Google Space a couple of days before the event.

**Example of adding attendees to a Google Space:**

![How to Add Team Member - Part 1](images/wth-add-team-member-01am.jpg)

![How to Add Team Member - Part 2](images/wth-add-team-member-02am.jpg)

When someone is added to a Space, they will be emailed to accept the invite and join the Space. **NOTE:** The user will need to "activate" Google Chat if they've never used it before. Be aware of this.

#### Calendar Invite

Calendar invites are always important so attendees don't forget about your event.
If someone is traveling to attend your event in person, they're not likely to forget to show up.  

When it comes to hosting a virtual gHacks event, a Calendar block is even MORE important. The key word is **BLOCK**! You need the attendees to clear their calendar so they are dedicated to participating in the hack for the full event. Attendees leaving part way through the hack are putting their team's success at risk.

We recommend sending a calendar invite to all registered attendees as early as possible after they have registered. If you are hosting an external organization, coordinate with the event stakeholder to send the calendar invite.

When you create a calendar invite, you should include:

- A brief description of the event format
- A mention that they should have received an invite email for the event's Google Space.
- Instructions to make arrangements for others to cover their day jobs.
- Instructions to turn on their Out of Office messages.

## Event Day 

The big day has arrived! It's showtime!  Rest well and get a full night of sleep beforehand. You will need it to be fresh on hack day.

Below is the guidance on how to actually host and run a gHacks event:

- [Kick-Off Meeting](#kick-off-meeting)
- [Hacking](#hacking)
- [Stand Ups](#stand-ups)
- [In-Person Event Tips](#tips-for-in-person)
- [Virtual Event Tips](#tips-for-virtual)
	
### Kick-Off Meeting 

Every gHacks event starts off with a Kick Off Meeting.  *How* you get to the kick off meeting depends on if it is a virtual or an in-person event.

#### Getting There: In Person

If you are hosting an in-person event, it is simple. Attendees show up at the venue you shared with them in your invite, take a seat, and give you their full attention to kick off.

The in-person attendees should be instructed to join the event's Google Space that they were invited to in email. Even though we'll be together in person during the hack, having access to a system to share files and code, etc is key.

#### Getting There: Virtual Event

Getting to the kick off meeting can be a little tricky for virtual attendees. They will not join the kick off meeting the way they normally join a Google Meet from a calendar invite. Instead they will join a Google Meet that is taking place inside of the event's Google Space.

As covered in the [previous section](#wth-event-preparation), attendees should have been added to the Google Space before the event based on registration.

The lead coach should start the kick off meeting in the Google Space 15-20 mins before the kick off by clicking camera icon in the chat text field. 

![Start a Channel Meeting](images/wth-kickoff-meeting-meet-now.jpg)

To join the kick off meeting, attendees will first open up Google Chat and go to the event's Google Space. In there, they will find the link to join the Google Meet that the lead coach created.

#### Welcomes & Intros

Now that you have everyone's attention, it is time to kick off by welcoming the attendees and introducing the coaches. If it is a virtual event, we recommend the coaches turn on their cameras during the kick off as it helps drive the collaboration and interaction with the group.

If the size of the group is small, it is a good idea to get to know your attendees by letting them introduce themselves.  Ask them to state their experience with the technology and what a successful event will look like for them.

For a large group, skip the attendee intros (no one wants to be the 25th person to introduce themselves). Instead, the coaches should have the attendees introduce themselves later when they split into their smaller teams.

#### Logistics

Once everyone is acquainted, the lead coach should cover the logistics. Start off by communicating the format and flow of the event. You should assume that the attendees are not familiar with the gHacks format.

Explain the format:

- Attendees will spend most of the time working in teams of 3-5 people to solve technical challenges.
- Challenges are not labs with step-by-step instructions. Attendees will need to work together as a team to solve the challenge by researching documentation and following guidance from the coaches.
- Teams will move at their own pace through the challenges and not be beholden to the clock.
- There may be brief lecture presentations to the entire group at various points throughout the event to set up the hack's challenges.
- Break times will be set for lunch and the end of each hack day, however each team can set additional break times as needed.
- The coaches will bring the teams together at the beginning and end of each day for stand-up meetings to review progress and what they learned during each challenge.

Next, review how everyone will interact using the event's Google Space. The lead coach should provide a tour of the event Space, including the File tab where the student resources for the hack are located. The link to the Student Guide and the Google Meet.

For a virtual event, the lead coach should explain how teams will use the breakout rooms to move into their team specific room and the larger meet.  Attendees should be expected to be online and engaged in their team meetings for the duration of the event with mic and camera turned on.

At an in-person event, coaches may walk from table to table helping coach different teams. At a virtual event, they do the same by popping in and out of each team's breakout room throughout the event. When the coaches want all squads to come together, they will announce on each squad's call to rejoin the main room.

#### Team Formation

Determine how you want to break the attendees up into the smaller groups to form the hack squads. There are several options to consider.

- At an in-person event, the squads can be set by the table the attendees sit at.
- Load balanced by skill level - This encourages a mix of experts and novices so that there is shared learning. Experts are encouraged to help novices.
- Segregated by skill level - This enables advanced participants to progress at a faster pace or take on additional challenges, while allowing novices to move at a less stressful pace as they work together to learn.
- Play Dodgeball - The lead coach nominates a few attendees as squad leaders. Allow the squad leaders to pick their squad members like in gym class at school.
- At a virtual event, given various attendee locations, you may form squads by timezone. This enables squads to take break times that align to their timezone.
- Random

**TIP:** If hosting a hack at an external organization, it is a good idea to ask the event stakeholder to help decide.

Once squads have been formed, encourage them to each give their squad a fun name and rename their Teams channel to it as depicted in the image below. This will help break the ice and get the squad members collaborating out of the gate.

#### Event Kick Off Presentation Templates

To help you get started, we have provided PowerPoint templates for kicking off a gHacks event here:
- [In-Person - Kick Off Presentation Template](WTH-InPerson-EventKickoff-Template)
- [Virtual - Kick Off Presentation Template](WTH-Virtual-EventKickoff-Template.md)

The kick off presentation templates contain most of the instructions above that you can present to the attendees before starting the gHacks. The in-person template has additional slides instructing attendees to use a code to join the event team in Microsoft Teams.

### Hacking

With the logistics out of the way, it is time to crank up the tech intensity.

#### Hack Presentation Lectures (Optional)

While not required, many of the hacks in the [gHacks collection](../README.md#the-ghacks-collection) have a PowerPoint deck with lecture presentations included the `/Host` folder of the hack. These optional lecture presentations typically contain:

- An overview of the technical scenario of the hack itself.
- A review of workstation pre-requisites needed for the hack.
- Overviews for each challenge including technology concepts needed to complete them.

Before the squads depart the kick-off meeting, the lead coach should cover the hack overview, prerequisites, and overview of technology concepts for the first challenge.

Later, throughout the event, the lead coach should work with the coaches to monitor progress of the squads on each challenge. When the majority of squads (or individuals in a squad) have completed a challenge, the lead coach should deliver the lecture for the next challenge. Ask those who are still working to pay attention to the short lecture, then return to completing the previous challenge.

At an in-person event, the lead coach calls everyone's attention to the front of the room to present. At a virtual event, the lead coach directs the squads to return to the General channel for the lecture.

Alternatively, if the squads are progressing at vastly different paces, the coaches may deliver the lecture for each challenge to the individual squad in their own squad meetings.

#### Hack Squads

Now it's time to get down to the business of solving the challenges as a squad. If you are hosting an in-person hack, attendees will start talking to each other and working together at their squad tables to solve the challenges.

If it is a virtual event, the attendees will leave the meeting in the General channel. They will then go to their squad's channel and participate in a meeting in that channel. Coaches should be prepared to assist folks and direct them where they need to go within Microsoft Teams.

Please be aware the first person enter the channel will hit the “Meet now” button within the channel (as indicated by the red arrow below) to start the channel meeting. All subsequent individuals will see a notice that there is an active meeting and can simply hit the “Join” button.

![Start a Squad Meeting](images/wth-squad-meet-now-buttonm.jpg)

Once everyone is settled, the format and interactions are the same whether virtual or in-person:

- The individuals within the squads can now work together on their tasks, share screens, links, etc. to help complete the challenges.
- Squads must complete the challenges as a team. Individuals who complete a challenge before their squad-mates should not continue to the next challenge. Instead, they should help other members of their squad get over the finish line.
- While the squad works together solve the challenges, it is expected that each individual contributes meaningfully to the group and completes the challenge on their own workstation.
- To ensure each individual is contributing to the team effort, we recommend one person be the "designated driver" for each challenge and share their screen with the squad as they work through the challenge for all to observe. The rest of the squad may be doing research or implementing the solution in parallel on their own workstation.
- As people get stuck the coaches should encourage them to talk through the issues with the squad and share their screen to work through the challenge. Group collaboration is a very effective learning tool.  
- If a person within the squad is having a problem that requires individual attention, the coach can ask the person to go to the coach’s dedicated channel where they can start a channel meeting and work together to resolve the issues.
- Sharing is caring. As individuals or squads find useful tips and tricks, or solve roadblocks, the coaches should encourage them to share those items in the General Channel as a Chat or within the Shared Tips document.
- Squads should not be beholden to the clock as they progress through the challenges. Therefore, they control their own schedule during the event and can decide to take breaks as needed outside of any scheduled meal breaks.

#### Hack Coaches

Coaches are essential to a gHacks event and can make the difference between a good experience or a poor experience for the attendees. Ideally, there should be one coach per squad. However, a coach can reasonably manage two squads at the same time if there are not enough coaches available.

A coach's main over-arching role is to act as a technical advisor to the attendees in a squad. Coaches are not proctors who stand on the sideline and wait for attendees to raise their hands for help. They should be actively engaged with the squad(s) they are advising the majority of the time.

At an in-person event, the coaches should be sitting at the table with their squad. At a virtual event, they should be engaged in their squad's channel meeting for the duration of the event.

Coaches will need to move around to interact with the lead coach, other coaches, or multiple squads. For example, a coach may ask another coach for help if a squad runs into an issue that the coach does not know how to solve.

At a virtual event, the coaches can quickly jump in and out of the various Squad channels to check in on the squad and provide support as required by joining the various channel meetings.

During the hack, a coach's responsibilities include:

- Keep the squads working as teams
    - Encourage attendees to “learn from” and “share with” each other
    - If a coach observes individuals racing ahead, encourage them to help those who are behind.
    - Encourage attendees to use their squad’s channel to collaborate/share info
	- Encourage attendees to take turns "driving" for each challenge so each gets an opportunity to lead their squad 
- Help unblock squads that get stuck
    - Always and repeatedly encourage squad members to unblock each other first
    - Provide hints, but not answers
	- Repeat and confirm the challenge goals if there is ambiguity
    - If a coach observes an individuals blocked for a while, help them get moving so they don’t lose interest and disengage.
- Be a technical advisor and subject matter expert
	- Provide hints/pointers to the squads on how to solve problems and where to find information.
    - Use the solutions in the Coach’s guide to provide guidance, but do not share with the attendees
    - The Coach’s guide will not be comprehensive. As subject matter experts, coaches should share their knowledge and explain key concepts to help the attendees
- Notify the lead coach of unexpected blockers that arise during the event so they can be communicated to all squads and recorded for future reference.
- Verify that a squad has completed each challenge by checking that they have met all of the success criterias.
- Solicit continuous feedback from the attendees on their experience, the content, and what can be done to improve it. Encourage them to use the Feedback channel to share with all of the coaches.

**NOTE:** Attendees should not be judged on how far they get.  No trophies should be given for challenge completion.  If event hosts want to gamify/incentivize attendees, they should focus on encouraging attendees to share with each other.

### Stand-Ups

Throughout the event, the coaches should have various checkpoints or stand-ups that require all the individuals to take a break from hacking to... stand up. This is a good thing to do before starting a scheduled meal break, at the end of each day, and start of each subsequent day of the hack.

Coaches may have stand ups with their individual squads, or the lead coach may call all attendees back to the General channel to address them as a group.

Things that coaches should facilitate during a stand up:
- Require the attendees to physically get up, stretch and take a minute away from their screens
- Ask for a quick status check of where the squad is on a given challenge
- Review next steps and plan going forward to solve the challenges
- Upon completion of a challenge, discuss the solution and re-cap lessons learned.
- Review a technical concept that the squad has struggled to understand

The lead coach should close out the gHacks event with a final stand-up that acts as a wrap-up session.
- Attendees should be encouraged to share their parting thoughts and key learnings.
- Attendee feedback should be solicited for a final time and notes collected by the lead coach
- Thank the attendees for their time and dedication during the hack
- Finally, share the content by directing the attendees to visit the gHacks repo on Github: <http://github.com/gfilicetti/gHacks>

You have now survived a gHacks!

### Tips for In Person

gHacks is designed to be a casual tech event. There are no formal requirements for hosting it in person other than a decent Internet connection.

If you have budget, spend it on food, glorious food!  Your attendees will appreciate you for that.

There are plenty of guides out there for hosting a great in-person event. There's not much more we can add here.

### Tips for Virtual

gHacks were designed to be hosted as an in-person or virtual event. While most details of ***how*** to hack were covered earlier in this document, we wanted to share some tips and lessons learned for improving the virtual experience based on previous gHacks events that have been hosted.

- Require attendees to keep an open mic and use cameras as often as possible. Noisy pets, kids, or spouses. It's all fine in the spirit of keeping remote attendees engaged and feeling as though they are together. Just remember to mute the toilet flushes!
- If a coach observes an individual on mute for long periods of time or not speaking up as the squad hacks, the coach should reach out in a private chat to ask the person if they need help. The goal is to keep the person engaged in the hack and away from their email, phone, social media, etc.
- If bandwidth is tight for an attendee, they can turn off their camera as well as the ***incoming*** video stream from other participants.
- Coaches should never turn their cameras off so that attendees know they are available, especially during any lectures or re-caps
- Stand-ups really need to be stand ups. Encourage attendees to take a break from their screen and headsets and walk around. Sitting at a desk for long periods is not healthy.

Remote attendees may be spread across timezones. There are multiple related learnings here:

- Attendees should be in a similar timezone region (+/- 3 hours) to optimize scheduling and collaboration.
- Coaches should also be in the same timezone region. However, coaches can adjust their schedule to support remote attendees in a different region if needed. For example, a North American coach can agree to wake up early (4am) to support a virtual event scheduled for the European region.
- Balance kick-off and end times across a time zone region with an early start for the western-most time zone and a later end time for the eastern-most time zone.  For example, if hosting an event for North American attendees, start at 7am Pacific/10am Eastern. End at 6pm Eastern/3pm Pacific.
- When forming squads, encourage folks to group by time zone. This allows the members of each squad to take the same lunch or dinner break together.
- For a multi-day hack, after a shared kick-off meeting on day 1, coaches can designate the hours they will be available on the subsequent days. The squads can then decide to start earlier/finish later if all members are in the same time zone. For example, coaches can be available 10am-6pm Eastern. A squad in the eastern time zone can start 9am and finish at 4pm. The squad in the western time zone can work the same hours in their own time zone, resulting in them working the last hour without a coach.

It is possible to host a "hybrid" event that has some attendees and coaches in person, and others remote. Here are recommendations from experiences we have had with different permutations:

- Hosting an in-person event with remote attendees.
	- Group remote attendees into one or more squads consisting only of remote attendees. Don't mix and match.
	- Dedicate an in-person coach to support the remote squads
	- The dedicated in-person coach is responsible for making sure the A/V connections between the venue and the event team in Microsoft Teams is working
	- The dedicated in-person coach must represent the remote attendees to the lead coach & other in-person attendees. When questions come up online, the dedicated in-person coach can be the one to get the attention of the lead or other in-person coaches.
- Hosting an event where the attendees are in-person, but the coaches are remote
	- This is a great solution when you want to host an event for attendees in a different region
	- The coaches need to adjust their working hours to support the remote region.  For example, to support an event in Australia, a coach in the eastern US time zone would need to agree to work from 5pm to 1am.
	- This does require volunteers to be designated as facilitators in the physical venue. The facilitators are responsible for the A/V connectivity to the remote coaches and raising questions from attendees in the venue to the online coaches.
- Hosting an event where individual squads work together in person, but distributed and remote from other squads. 
	- For example, squads can work together in New York, Chicago, and Seattle. The lead coach may be in Chicago leading all three groups online. 