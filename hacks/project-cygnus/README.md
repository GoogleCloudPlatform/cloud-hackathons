# Project Cygnus

## Introduction

Welcome, security analyst! You have been contracted by a fast-growing (and slightly chaotic) startup, Cygnus Corp, to perform a security assessment of their new cloud-native data processing pipeline. This environment has been rapidly developed and deployed on Google Cloud, and your job is to identify and trace a path through the vulnerabilities before a real adversary does.

This Capture The Flag (CTF) challenge is a hands-on lab designed to simulate a real-world cloud security investigation. You will navigate through a series of misconfigurations across various Google Cloud services, starting from an initial reconnaissance phase and moving all the way through to a final "exfiltration" objective.

Your success will depend not on a single exploit, but on your ability to connect the dots between seemingly unrelated services and understand how a small oversight in one area can create a significant risk in another.

## Learning Objectives

This CTF is designed to provide practical, hands-on experience. Upon completion, you will be able to:

1. Identify Common Cloud Misconfigurations: Recognize and assess the risk of publicly accessible storage buckets and overly permissive IAM roles.
2. Analyze and Secure a CI/CD Pipeline: Understand the risks of insecure base images in containers, create and configure a secure Artifact Registry repository, and use Cloud Build to automate the build process.
3. Deploy and Secure Cloud-Native Applications: Deploy a containerized application to Cloud Run and understand how to configure its network access and authentication settings.
4. Evaluate Cloud Security Posture: Use Security Command Center to identify active findings and assess the importance of data-access audit logging and automated event-driven responses for security incidents.
5. Utilize a Breadth of Google Cloud Services: Gain hands-on familiarity with Cloud Storage, Cloud Functions, Artifact Registry, Cloud Build, Cloud Run, and Vertex AI.

## Challenges

- Your mission is to work through five distinct stages, each representing a step in a potential attack path.

**Challenge 1: Initial Reconnaissance**

**Objective:** Find the initial entry point into the Cygnus Corp environment.

**Task:** Begin by enumerating public cloud resources. You need to find an exposed asset and understand the automated process it triggers.

**Challenge 2: Supply Chain Analysis**

**Objective: **Investigate the application's dependencies and identify a key vulnerability in its software supply chain.

**Task:** Locate the application's source code, analyze its Dockerfile for weaknesses, and create a secure, private repository for your "blessed" artifacts.

**Challenge 3 & 4: Build and Deploy**

**Objective:** Take control of the build process and deploy a public-facing application.

**Task:** Create a CI/CD build configuration from scratch. Use Cloud Build to construct a container from the source code and deploy it as a new, publicly accessible service on Cloud Run.

**Challenge 5: Objective & Evasion**

**Objective:** Complete the final action using the deployed application while identifying gaps in the environment's security monitoring and response capabilities.

**Task:** Use the application's intended functionality to run a job on Vertex AI. In parallel, investigate the project's security posture to see if your actions are being logged and if security findings are being automatically remediated.


## Prerequisites

- Google Cloud Project: You will be provided with a unique Google Cloud Project ID.
- Cloud Console & Shell: Familiarity with navigating the Google Cloud Console and using the Cloud Shell terminal. All required commands can be executed from Cloud Shell.
- Basic Linux Command-Line Knowledge: You should be comfortable with basic commands like ls, cd, and using a text editor like nano or vim to create and edit files.
- Conceptual Understanding of Docker: You should understand what a Dockerfile is and the basic concepts of building, tagging, and pushing container images. You do not need to be an expert.

## Contributors

- Mohamed Fawzi (vFawzi)

## Stage 1: Secure the Foundation and Data Governance

System Overview: The platform's entry point is an automated ingestion pipeline that receives raw telemetry from partner ICS networks across the country. This data is the lifeblood of our AI, but it is also highly sensitive, potentially containing location information and operator details.

High-Level Objective: Your objective is to establish and enforce a robust data governance and security baseline for the entire project. This includes controlling where data can be physically stored to meet regulatory requirements, ensuring sensitive information within the raw data streams is properly handled before processing, and applying the principle of least privilege to the initial data-handling identities.

## Stage 2: Harden the Software Supply Chain

System Overview: A containerized application, built via an automated CI/CD pipeline in Cloud Build, is responsible for pre-processing the raw telemetry. The integrity of this application is paramount; if it were to be compromised, all downstream analysis would be untrustworthy.

High-Level Objective: Your objective is to secure the entire software supply chain for this data processing application. You must ensure we are building from trusted, vulnerability-scanned base images and enforce a technical policy that guarantees only verifiably built and untampered artifacts can be deployed into our environment.


## Stage 3: Isolate the Crown Jewels (ML Training)


System Overview: This stage focuses on the Vertex AI environment where the core threat-detection model is trained. This is our "crown jewels"—where raw data is transformed into priceless intellectual property. A breach here could lead to model theft or manipulation.

High-Level Objective: Your objective is to create a completely sealed, private, and customer-controlled environment for the ML training process. This environment must be immune to data exfiltration, and all sensitive data and model artifacts within it must be encrypted using cryptographic keys that we, not the cloud provider, control. The identities used for training must be ephemeral and possess the absolute minimum required privileges.


## Stage 4: Defend the Public Gateway


System Overview: The fruits of our labor—real-time threat intelligence—are provided to our partner federal agencies via a public-facing API. This "front door" is the most visible part of our platform and will be the primary target for external attacks.

High-Level Objective: Your objective is to secure the public-facing API gateway. You must implement multiple layers of defense, including strong, centralized authentication for all users, protection against common web application attacks and DDoS attempts, and real-time, AI-specific security to prevent model manipulation or sensitive data leakage through the API itself.


## Stage 5: Achieve Continuous Assurance


System Overview: Our security work is not a one-time task. The platform will evolve, new code will be deployed, and developers may make mistakes. We must build a system that maintains its security posture over time.

High-Level Objective: Your objective is to implement a framework for continuous security assurance. This involves establishing a complete, non-repudiable audit trail for all sensitive data access, using GCP's native security posture management tools to continuously scan for and detect new misconfigurations, and building an automated response workflow to remediate critical vulnerabilities the moment they are detected.




### Pre-requisites (Optional)

*Include any technical pre-requisites needed for this challenge specifically.  Typically, it is completion of one or more of the previous challenges if there is a dependency. This section is optional and may be omitted.*

### Introduction (Optional)

*This section should provide an overview of the technologies or tasks that will be needed to complete the this challenge.  This includes the technical context for the challenge, as well as any new "lessons" the attendees should learn before completing the challenge.*

- *Optionally, the coach or event host is encouraged to present a mini-lesson (with the provided lectures presentation or maybe a video) to set up the context and introduction to each challenge. A summary of the content of that mini-lesson is a good candidate for this Introduction section*

*For example:*

When setting up an IoT device, it is important to understand how 'thingamajigs' work. Thingamajigs are a key part of every IoT device and ensure they are able to communicate properly with edge servers. Thingamajigs require IP addresses to be assigned to them by a server and thus must have unique MAC addresses. In this challenge, you will get hands on with a thingamajig and learn how one is configured.

### Description

*This section should clearly state the goals of the challenge and any high-level instructions you want the students to follow. You may provide a list of specifications required to meet the goals. If this is more than 2-3 paragraphs, it is likely you are not doing it right.*

> [!IMPORTANT]  
> *Do NOT use ordered lists as that is an indicator of 'step-by-step' instructions. Instead, use bullet lists to list out goals and/or specifications.*

> [!NOTE]  
> *You may use Markdown sub-headers to organize key sections of your challenge description.*

*Optionally, you may provide resource files such as a sample application, code snippets, or templates as learning aids for the students. These files are stored in the hack's `resources` sub-folder. It is the coach's responsibility to package these resources and provide them to students in the Google Space's Files section as per [the instructions provided](https://ghacks.dev/faq/howto-host-hack.html#making-resources-available).*

> [!NOTE]  
> *Do NOT provide direct links to files or folders in the gHacks Github repository from the student guide. Instead, you should refer to the "resources in the Google Space Files section".*

*Here is some sample challenge text for the IoT Hack Of The Century:*

In this challenge, you will properly configure the thingamajig for your IoT device so that it can communicate with the mother ship.

You can find a sample `thingamajig.config` file in the Files section of this hack's Google Space provided by your coach. This is a good starting reference, but you will need to discover how to set exact settings.

Please configure the thingamajig with the following specifications:

- Use dynamic IP addresses
- Only trust the following whitelisted servers: "mothership", "IoTQueenBee"
- Deny access to "IoTProxyShip"

### Success Criteria

- *Success criteria go here. The success criteria should be a list of checks so a student knows they have completed the challenge successfully. These should be things that can be demonstrated to a coach.*
- *The success criteria should not be a list of instructions.*
- *Success criteria should always start with language like: "Validate XXX..." or "Verify YYY..." or "Show ZZZ..." or "Demonstrate VVV..."*

*Sample success criteria for the IoT sample challenge:*

- Verify that the IoT device boots properly after its thingamajig is configured.
- Verify that the thingamajig can connect to the mothership.
- Demonstrate that the thingamajig will not connect to the IoTProxyShip

### Tips

*This section is optional and may be omitted.*

*Add tips and hints here to give students food for thought. Sample IoT tips:*

- IoTDevices can fail from a broken heart if they are not together with their thingamajig. Your device will display a broken heart emoji on its screen if this happens.
- An IoTDevice can have one or more thingamajigs attached which allow them to connect to multiple networks.

### Learning Resources

*This is a list of relevant links and online articles that should give the attendees the knowledge needed to complete the challenge.*

*Think of this list as giving the students a head start on some easy Internet searches. However, try not to include documentation links that are the literal step-by-step answer of the challenge's scenario.*

> [!NOTE]  
> *Use descriptive text for each link instead of just URLs.*

*Sample IoT resource links:*

- [What is a Thingamajig?](https://www.google.com/search?q=what+is+a+thingamajig)
- [10 Tips for Never Forgetting Your Thingamajig](https://www.youtube.com/watch?v=dQw4w9WgXcQ)
- [IoT & Thingamajigs: Together Forever](https://www.youtube.com/watch?v=yPYZpwSpKmA)

### Advanced Challenges (Optional)

*If you want, you may provide additional goals to this challenge for folks who are eager.*

*This section is optional and may be omitted.*

*Sample IoT advanced challenges:*

Too comfortable?  Eager to do more?  Try these additional challenges!

- Observe what happens if your IoTDevice is separated from its thingamajig.
- Configure your IoTDevice to connect to BOTH the mothership and IoTQueenBee at the same time.
