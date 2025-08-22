# Project Cygnus

## Introduction

Welcome, agent, to Project Cygnus.

You've just been dropped into the cloud environment of "Cygnus Corp," the galaxy's fastest-growing (and most chaotic) tech startup. They move fast, break things, and their security policy seems to be written on a napkin that’s currently on fire. They’ve built a revolutionary data processing pipeline that’s poised to change the world... or get them completely owned by the first person who rattles the doorknob.

That’s where you come in.

You are an elite cyber operative, a digital ghost, a "security professional" (which is a fancy way of saying you get paid to break stuff). Your mission, should you choose to accept it, is to navigate this minefield of misconfigurations, find the security holes before the actual bad guys do, and trace the path from a simple public file to the company’s crown jewels.

Forget everything you know about boring tutorials. This is a digital safari. A high-stakes puzzle box. A playground of things you should never do in a real production environment. So grab your keyboard, fire up your terminal, and let's go see what skeletons are hiding in Cygnus's cloud.

## Learning Objectives

By the time you emerge from this digital rabbit hole, you won't just have a certificate; you'll have some serious real-world skills. Here’s what you’ll be able to do:

- Become a Digital Locksmith: You'll learn to spot a digital door that’s not just unlocked but completely missing. You'll understand how service accounts work and why giving one the keys to the entire kingdom is a hilariously bad idea.
- Master the Art of the Supply Chain Heist: You'll see how a lazy choice made by a developer six months ago (like using a random base image from the internet) can be the thread you pull to unravel everything. You’ll learn how code gets from a laptop to the cloud and how to stop villains from hijacking the delivery truck.
- Think Like a Cloud Detective: You'll learn to follow the digital breadcrumbs from one service to another, connecting the dots between a storage bucket, a function, a build pipeline, and a running application. This is about seeing the whole crime scene, not just the fingerprints.
- Build Your Own Security Roomba: You'll discover what happens when nobody's watching (hello, disabled audit logs!) and why having a security system that just tells you something is on fire isn't as good as one that actually finds a fire extinguisher.



## Challenges

- Challenge 1: The Front Door's Wide Open
  - Your first task is simple: walk through the front door. Somewhere in this project, there's a welcome mat laid out for the entire internet. Find it, see what it's connected to, and get your first foothold.
- Challenge 2: The Trojan Docker
  - You’ve found the application's source code! But its family tree is... questionable. Your mission is to investigate its origins, spot the inherited security flaw, and set up a "secure" area for your own tools.
- Challenge 3 & 4: Build It, Break It, Ship It
  - Time to get your hands dirty. You’ll take their flawed blueprint, build your own version of their application using their own tools, and deploy it for the world to see. Let's see what happens when you control the assembly line.
- Challenge 5: The Ghost in the Machine
  - The system is live! Now, can you use it for your own purposes? Your final challenge is to perform a high-impact action while trying not to set off any alarms. The question is... are there any alarms to set off?

## Prerequisites

To embark on this glorious mission, you'll need a few things in your kit:

- Your Digital Sandbox: A Google Cloud Project where you have permission to play. We’ve set up the basics; your job is to make the glorious mess.

- Your Magic Wand (and Crowbar): Access to the Cloud Shell or a local terminal with the gcloud SDK installed. This is where you'll cast the spells.

- A Map and a Compass: You should know how to navigate a command line without accidentally typing rm -rf /. You've heard of "the cloud," and you know it’s just someone else's computer.

- A Healthy Dose of Curiosity: Your most important tool. A burning desire to poke things with a digital stick to see what happens. Don't be afraid to break things—that's literally the whole point.

- Cyber-Fuel: Coffee, tea, energy drinks, or just pure, unadulterated spite. Whatever keeps your fingers flying.

## Contributors

- Mohamed Fawzi


**Project Cygnus: Capture The Flag - Participant Guide**

# 1. Mission Briefing 

Welcome, Security Operations Team.

You have been selected for a high-stakes engagement of national importance. Our organization, in partnership with federal agencies, has developed "Project Cygnus," an AI-powered threat intelligence platform designed to protect national critical infrastructure. The platform ingests and analyzes highly sensitive telemetry from industrial control systems (ICS) across the country, using advanced machine learning to detect and predict sophisticated cyber-attacks in real-time.

Given its mission, Project Cygnus is considered a Tier 1 strategic asset and is an extremely high-value target for well-funded, nation-state adversaries.

The platform is functionally complete, but it was assembled rapidly by multiple development teams. A preliminary review suggests that while individual components work, the overarching security architecture has significant gaps. Your team has been granted full "blue team" (remediation) privileges and charged with a single, critical mission: harden the entire Project Cygnus platform against a sophisticated attacker.

This is not a traditional Capture The Flag exercise. There are no hidden flags or simple tricks. Success is defined by your ability to analyze a complex cloud architecture, identify multiple interconnected vulnerabilities, and re-architect the system to a verifiable, defense-in-depth security posture.

For each stage of this engagement, you will be given a high-level security objective. It is up to you to investigate the environment, identify all the flaws within that subsystem, and implement the necessary controls. When you believe you have met the objective, you will report to the CISO (your trainer) for a full architectural review and validation.
The security of the nation's infrastructure is now in your hands. Good luck.

# 2. RULES OF ENGAGEMENT
**Scope:** All activities must be confined to your assigned GCP Project (cygnus-ctf-[team-name]). Activities outside this project are strictly prohibited.
****Permissions:** **You have been granted elevated IAM permissions to allow for full investigation and remediation of services within the project. Your goal is to fix vulnerabilities, not exploit them destructively.
****No Attacks on GCP:** **Attacking the underlying Google Cloud infrastructure itself is out of scope and forbidden.
****Validation:** **When your team believes a stage is fully hardened and its objective has been met, notify your CISO (trainer) for a validation session. Be prepared to explain and justify your architectural changes.

# 3. STAGE BRIEFINGS
**Stage 1: Secure the Foundation and Data Governance**
**System Overview:** The platform's entry point is an automated ingestion pipeline that receives raw telemetry from partner ICS networks across the country. This data is the lifeblood of our AI, but it is also highly sensitive, potentially containing location information and operator details.
**High-Level Objective:** Your objective is to establish and enforce a robust data governance and security baseline for the entire project. This includes controlling where data can be physically stored to meet regulatory requirements, ensuring sensitive information within the raw data streams is properly handled before processing, and applying the principle of least privilege to the initial data-handling identities.


**Stage 2: Harden the Software Supply Chain**
**System Overview:** A containerized application, built via an automated CI/CD pipeline in Cloud Build, is responsible for pre-processing the raw telemetry. The integrity of this application is paramount; if it were to be compromised, all downstream analysis would be untrustworthy.
****High-Level Objective: ****Your objective is to secure the entire software supply chain for this data processing application. You must ensure we are building from trusted, vulnerability-scanned base images and enforce a technical policy that guarantees only verifiably built and untampered artifacts can be deployed into our environment.

**Stage 3: Isolate the Crown Jewels (ML Training)**
**System Overview:** This stage focuses on the Vertex AI environment where the core threat-detection model is trained. This is our "crown jewels"—where raw data is transformed into priceless intellectual property. A breach here could lead to model theft or manipulation.
****High-Level Objective: ****Your objective is to create a completely sealed, private, and customer-controlled environment for the ML training process. This environment must be immune to data exfiltration, and all sensitive data and model artifacts within it must be encrypted using cryptographic keys that we, not the cloud provider, control. The identities used for training must be ephemeral and possess the absolute minimum required privileges.

**Stage 4: Defend the Public Gateway**
**System Overview:** The fruits of our labor—real-time threat intelligence—are provided to our partner federal agencies via a public-facing API. This "front door" is the most visible part of our platform and will be the primary target for external attacks.
**High-Level Objective:** Your objective is to secure the public-facing API gateway. You must implement multiple layers of defense, including strong, centralized authentication for all users, protection against common web application attacks and DDoS attempts, and real-time, AI-specific security to prevent model manipulation or sensitive data leakage through the API itself.

**Stage 5: Achieve Continuous Assurance**
**System Overview:** Our security work is not a one-time task. The platform will evolve, new code will be deployed, and developers may make mistakes. We must build a system that maintains its security posture over time.
**High-Level Objective:** Your objective is to implement a framework for continuous security assurance. This involves establishing a complete, non-repudiable audit trail for all sensitive data access, using GCP's native security posture management tools to continuously scan for and detect new misconfigurations, and building an automated response workflow to remediate critical vulnerabilities the moment they are detected.

End of Briefing


