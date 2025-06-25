# Media & Entertainment on Google Cloud

## Introduction

The Media & Entertainment on Google Cloud gHack will take you on a whirlwind tour in the world of media technology and how it is being used in the modern world of cloud based and AI services.

## Learning Objectives

In this hack you will be solving the common business problems that all companies in the Media & Entertainment industry are facing and how Google Cloud and our AI solutions fit in:

1. Provision appliances
1. Set up SRT sources
1. Create advert visuals

## Challenges

- Challenge 1: Provision an environment
  - Create an environments and run tests to ensure it works
- Challenge 2: Your First Stream
  - Make the connection to the SRT streams and properly provision and connect them
- Challenge 3: Advertising Makes the World Go 'Round
  - Create some ad content and insert ads into your streams
- Challenge 4: Scalable Play-out
  - Figure out the play-out problem in the world media. How do we had large audiences

## Prerequisites

- Basic knowledge of GCP
- Access to a GCP environment

## Contributors

- Gino Filicetti
- Jane Q. Public
- Joe T. Muppet

## Challenge 1: Provision an environment

***This is a template for a single challenge. The italicized text provides hints & examples of what should or should NOT go in each section. You should remove all italicized & sample text and replace with your content.***

> **Note**
> *Use this format for sample informational blockquote, the Note part is case sensitive*

> **Warning**
> *Use this format for sample warning blockquote, the Warning part is case sensitive*

### Pre-requisites (Optional)

*Include any technical pre-requisites needed for this challenge specifically.  Typically, it is completion of one or more of the previous challenges if there is a dependency. This section is optional and may be omitted.*

### Introduction (Optional)

*This section should provide an overview of the technologies or tasks that will be needed to complete the this challenge.  This includes the technical context for the challenge, as well as any new "lessons" the attendees should learn before completing the challenge.*

- *Optionally, the coach or event host is encouraged to present a mini-lesson (with the provided lectures presentation or maybe a video) to set up the context and introduction to each challenge. A summary of the content of that mini-lesson is a good candidate for this Introduction section*

*For example:*

When setting up an IoT device, it is important to understand how 'thingamajigs' work. Thingamajigs are a key part of every IoT device and ensure they are able to communicate properly with edge servers. Thingamajigs require IP addresses to be assigned to them by a server and thus must have unique MAC addresses. In this challenge, you will get hands on with a thingamajig and learn how one is configured.

### Description

*This section should clearly state the goals of the challenge and any high-level instructions you want the students to follow. You may provide a list of specifications required to meet the goals. If this is more than 2-3 paragraphs, it is likely you are not doing it right.*

> **Note** *Do NOT use ordered lists as that is an indicator of 'step-by-step' instructions. Instead, use bullet lists to list out goals and/or specifications.*

> **Note** *You may use Markdown sub-headers to organize key sections of your challenge description.*

*Optionally, you may provide resource files such as a sample application, code snippets, or templates as learning aids for the students. These files are stored in the hack's `resources` sub-folder. It is the coach's responsibility to package these resources and provide them to students in the Google Space's Files section as per [the instructions provided](https://ghacks.dev/faq/howto-host-hack.html#making-resources-available).*

> **Note** *Do NOT provide direct links to files or folders in the gHacks Github repository from the student guide. Instead, you should refer to the "resources in the Google Space Files section".*

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

> **Note** *Use descriptive text for each link instead of just URLs.*

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

### Environment Setup

Define environment variables to run Terraform.
```
export TARGET_ORGANIZATION_ID=<your-target-organization-id>
export SOURCE_ORGANIZATION_ID=<your-source-organization-id>

export GCP_PROJECT_ID_SOURCE=<your-source-project-id>

export GCP_PROJECT_ID=<you-project-id>
export GCP_REGION=europe-west2
export GCP_ZONE=europe-west2-b
```

Setup necessaey org policies to run the Terraform script.
```
for f in policy_source.yaml.template policy_target.yaml.template; do
    sed "s|\$GCP_PROJECT_ID_SOURCE|$GCP_PROJECT_ID_SOURCE|g; s|\$TARGET_ORGANIZATION_ID|$TARGET_ORGANIZATION_ID|g; s|\$GCP_PROJECT_ID|$GCP_PROJECT_ID|g" "$f" > "${f%.template}"
done
```

Set necessary policies. Make sure the proper org administrator and project

Apply policy_source.yaml to the source project
```
gcloud org-policies set-policy policy_source.yaml
```

Apply policy_target.yaml to the target project
```
gcloud org-policies set-policy policy_target.yaml
```

Run Terraform `init`, `plan`, and `apply`.
```tf
terraform init

terraform plan \
  -out=out.tfplan \
  -var "gcp_project_id=${GCP_PROJECT_ID}" \
  -var "gcp_region=${GCP_REGION}" \
  -var "gcp_zone=${GCP_ZONE}"

terraform apply "out.tfplan" \
  -auto-approve
```
