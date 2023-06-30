# Intro to GKE: Deploy, Scale and Update

## Introduction

Welcome to the coach's guide for the Intro to GKE gHack. Here you will find links to specific guidance for coaches for each of the challenges.

> **Note** If you are a gHacks participant, this is the answer guide. Don't cheat yourself by looking at this guide during the hack!

## Coach's Guides

- Challenge 1: Provision a GKE Cluster
   - Create a new GKE cluster that you'll use to deploy, scale and update your application
- Challenge 2: Containerizing your Application
   - Run your application in a stand alone fashion and then containerize it to prepare it for deployment to GKE
- Challenge 3: Deploy and Expose the Application
   - Using your containerized app in Artifact Registry, deploy it to GKE and expose it to the public internet
- Challenge 4: Scale the Application to Handle Increased Traffic
   - Now that the application is deployed and out there, we've noticed an increase in traffic and need to scale out to handle the new load
- Challenge 5: Update and Release with Zero Downtime
   - Change is inevitable, but new releases need to be deployed smoothly. Here we learn how to do that with zero downtime

## Coach Prerequisites

This hack has pre-reqs that a coach is responsible for understanding and/or setting up BEFORE hosting an event. Please review the [gHacks Hosting Guide](https://ghacks.dev/faq/howto-host-hack.html) for information on how to host a hack event.

The guide covers the common preparation steps a coach needs to do before any gHacks event, including how to properly setup Google Meet and Chat Spaces.

### Student Resources

Before the hack, it is the Coach's responsibility create and make available needed resources including: 
- Files for students
- Terraform scripts for setup (if running this gHack in a customer's environment)

Follow [these instructions](https://ghacks.dev/faq/howto-host-hack.html#making-resources-available) to create the zip files needed and upload them to your gHack's Google Space's Files area. 

Always refer students to the [gHacks website](https://ghacks.dev) for the student guide: [https://ghacks.dev](https://ghacks.dev)

> **Note** Students should **NOT** be given a link to the gHacks Github repo before or during a hack. The student guide intentionally does **NOT** have any links to the Coach's guide or the GitHub repo.

## Challenge 1: Provision a GKE Cluster

### Notes & Guidance

Students will be doing XXX here, there are a few things to keep an eye on:

- Thing 1
- Thing 2

### Step By Step Walk-through
Follow the steps below to create a cluster named **fancy-cluster** with **3** nodes:

```bash
gcloud container clusters create fancy-cluster --num-nodes 3 --zone us-central1-c
```

It may take several minutes for the cluster to be created. Afterward, run the following command and see the cluster's three worker virtual machine (VM) instances:

```bash
gcloud compute instances list
```

**Output:**

```bash
NAME                                          ZONE        MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP    STATUS
gke-fancy-cluster-default-pool-ad92506d-1ng3  us-east4-a  n1-standard-1               10.150.0.7   XX.XX.XX.XX    RUNNING
gke-fancy-cluster-default-pool-ad92506d-4fvq  us-east4-a  n1-standard-1               10.150.0.5   XX.XX.XX.XX    RUNNING
gke-fancy-cluster-default-pool-ad92506d-4zs3  us-east4-a  n1-standard-1               10.150.0.6   XX.XX.XX.XX    RUNNING
```

You can also view your cluster and related information in the Cloud Console. Click the menu button in the top-left corner, scroll down to Kubernetes Engine and click Clusters. You should see your cluster named `fancy-cluster`.

![GKE Menu](images/gke-menu.png)
![GKE Clusters](images/gke-clusters.png)

Congratulations! You created your first cluster!

> **Note** If you're using an existing GKE cluster or if you created a cluster through Cloud Console, then you need to run the following command to retrieve the cluster's credentials and configure the kubectl command-line tool with them:
>
> `gcloud container clusters get-credentials fancy-cluster`
>
> If you already created a cluster with the gcloud container clusters create command listed above, then you do not need to complete this step.

## Challenge 2: Containerizing your Application

### Notes & Guidance

Students will be doing XXX here, there are a few things to keep an eye on:

- Thing 1
- Thing 2

### Step By Step Walk-through
Because this is an existing website, you only need to clone the source from the repository so that you can focus on creating Docker images and deploying to GKE.

Run the following commands to clone the source repository to your Cloud Shell instance and change it to the appropriate directory. You will also install the Node.js dependencies so that you can test your application before deploying it.

```bash
cd ~
git clone https://github.com/googlecodelabs/monolith-to-microservices.git
cd ~/monolith-to-microservices
./setup.sh
```

That clones the repository, changes the directory, and installs the dependencies needed to locally run your application. It may take a few minutes for that script to run.

Do your due diligence and test your application. Run the following command to start your web server:

```bash
cd ~/monolith-to-microservices/monolith
npm start
```

**Output:**

```
Monolith listening on port 8080!
```

You can preview your application by clicking the web preview icon in the Cloud Shell menu and selecting Preview on port 8080.

![Web Preview Menu](images/web-preview.png)

That should open a new window where you can see your Fancy Store in action!

![Fancy Store](images/fancy-store-original.png)

You can close that window after viewing the website. Press `Control+C` (Windows or Mac) in the terminal window to stop the web server process.

Now that your source files are ready to go, it's time to Dockerize your application.

Normally, you would have to take a two-step approach that entails building a Docker container and pushing it to a registry to store the image that GKE pulls from. However, you can make life easier by using Cloud Build to create the Docker container and put the image in the Container Registry with a single command. (To view the manual process of creating a docker file and pushing it, see [Quickstart for Container Registry](https://cloud.google.com/container-registry/docs/quickstart).)

Cloud Build compresses the files from the directory and moves them to a Cloud Storage bucket. The build process then takes the files from the bucket and uses the Dockerfile to run the Docker build process. Because you specified the `--tag` flag with the host as `gcr.io` for the Docker image, the resulting Docker image gets pushed to the Container Registry.

Run the following command in Cloud Shell to start the build process:

```bash
cd ~/monolith-to-microservices/monolith
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/monolith:1.0.0 .
```

That process takes a few minutes, but after it's completed, you can see the following output in the terminal:

```
ID                                    CREATE_TIME                DURATION  SOURCE                                                                                  IMAGES                              STATUS
1ae295d9-63cb-482c-959b-bc52e9644d53  2019-08-29T01:56:35+00:00  33S       gs://<PROJECT_ID>_cloudbuild/source/1567043793.94-abfd382011724422bf49af1558b894aa.tgz  gcr.io/<PROJECT_ID>/monolith:1.0.0  SUCCESS
```

To view your build history or watch the process in real time, you can go to the Cloud Console. Click the menu button in the top-left corner, scroll down to CI/CD, then click Cloud Build, and finally click History. There, you can see a list of your previous builds, but there should only be the one that you created.

![Build History](images/build-history.png)

If you click on Build id, then you can see all the details for that build, including the log output.

On the build details page, you can view the container image that was created by clicking on the Image name in the build information section.

![Build Details](images/build-details.png)


## Challenge 3: Deploy and Expose the Application

### Notes & Guidance

Students will be doing XXX here, there are a few things to keep an eye on:

- Thing 1
- Thing 2

### Step By Step Walk-through

Now that you containerized your website and pushed the container to the Container Registry, you can deploy it to Kubernetes.

To deploy and manage applications on a GKE cluster, you must communicate with the Kubernetes cluster-management system. You typically do that by using the `kubectl` command-line tool.

Kubernetes represents applications as [Pods](https://kubernetes.io/docs/concepts/workloads/pods/pod), which are units that represent a container (or group of tightly coupled containers). The Pod is the smallest deployable unit in Kubernetes. Here, each Pod only contains your monolith container.

To deploy your application, you need to create a [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/).  A Deployment manages multiple copies of your application—called replicas—and schedules them to run on the individual nodes in your cluster. In this case, the Deployment will run only one Pod of your application. Deployments ensure that by creating a [ReplicaSet](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/).  The ReplicaSet is responsible for making sure that the number of replicas specified are always running.

The `kubectl create deployment` command causes Kubernetes to create a Deployment named **monolith** on your cluster with **1** replica.

Run the following command to deploy your application:

```bash
kubectl create deployment monolith --image=gcr.io/${GOOGLE_CLOUD_PROJECT}/monolith:1.0.0
```

> **Note** As a best practice, you should use YAML files and a source control system, such as GitHub or Cloud Source Repositories, to store those changes. For more information, see [Deployments](https://kubernetes.io/docs/concepts/services-networking/service/).

#### Verify deployment

To verify that the Deployment was created successfully, run the following command (It may take a few moments for the Pod status to be "Running"):

```bash
kubectl get all
```

**Output:**

```bash
NAME                            READY   STATUS    RESTARTS   AGE
pod/monolith-7d8bc7bf68-htm7z   1/1     Running   0          6m21s

NAME                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.27.240.1   <none>        443/TCP   24h

NAME                       DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/monolith   1         1         1            1           20m

NAME                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/monolith-7d8bc7bf68   1         1         1       20m
```

That output shows you several things. You can see your Deployment, which is current; your ReplicaSet, with a desired Pod count of one; and your Pod, which is running. Looks like you successfully created everything!

> **Note** You can also view your Kubernetes deployments via the Cloud Console. Navigate to the top-left menu, then click **Kubernetes Engine &gt; Workloads**.

> **Note** If you see unexpected errors or statuses, then you can debug your resources by using the following commands to see detailed information about them:
>
> `kubectl describe pod monolith`
>
> `kubectl describe pod/monolith-7d8bc7bf68-2bxts`
>
> `kubectl describe deployment monolith`
>
> `kubectl describe deployment.apps/monolith`
>
> At the very end of the output, you will see a list of events that give errors and detailed information about your resources.

To individually view your resources, you can run the following commands:

```bash
# Show pods
kubectl get pods

# Show deployments
kubectl get deployments

# Show replica sets
kubectl get rs

#You can also combine them
kubectl get pods,deployments
```

To see the full benefit of Kubernetes, you can simulate a server crash, delete the Pod, and see what happens.

Copy your pod name from the previous command and run the following command to delete it:

```bash
kubectl delete pod/<POD_NAME>
```

If you are fast enough, you can run the previous command to see all again and you should see two Pods, one terminating and the other creating or running:

```bash
kubectl get all
```

**Output:**

```bash
NAME                            READY   STATUS        RESTARTS   AGE
pod/monolith-7d8bc7bf68-2bxts   1/1     Running       0          4s
pod/monolith-7d8bc7bf68-htm7z   1/1     Terminating   0          9m35s

NAME                 TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.27.240.1   <none>        443/TCP   24h

NAME                       DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/monolith   1         1         1            1           24m

NAME                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/monolith-7d8bc7bf68   1         1         1       24m
```

Why did that happen? The ReplicaSet saw that the pod was terminating and triggered a new pod to keep up the desired replica count. Later on, you'll see how to scale to ensure that you have several instances running so that if one goes down, your users won't see any downtime!

#### Expose GKE deployment

You deployed your application to GKE, but you don't have a way of accessing it outside of the cluster. By default, the containers you run on GKE are not accessible from the internet because they do not have external IP addresses.  You must explicitly expose your application to traffic from the internet via a [Service](https://kubernetes.io/docs/concepts/services-networking/service/) resource. A Service provides networking and IP support for your app's Pods. GKE creates an external IP and a load balancer ([subject to billing](https://cloud.google.com/compute/all-pricing#lb)) for your app.

Run the following command to expose your website to the internet:

```bash
kubectl expose deployment monolith --type=LoadBalancer --port 80 --target-port 8080
```

**Output:**

```bash
service/monolith exposed
```

#### Accessing the service

GKE assigns the external IP address to the Service resource—not the Deployment.  If you want to find the external IP that GKE provisioned for your application, you can inspect the Service with the kubectl get service command:

```bash
kubectl get service
```

**Output:**

```bash
NAME         CLUSTER-IP      EXTERNAL-IP     PORT(S)          AGE
monolith     10.3.251.122    203.0.113.0     80:30877/TCP     3d
```

After you determine the external IP address for your app, copy it. Point your browser to that URL (such as http://203.0.113.0) to check whether your app is accessible.

![Fancy Store](images/fancy-store-original.png)

You should see the same website that you tested earlier. Congratulations! Your website fully runs on Kubernetes.

## Challenge 4: Scale the Application to Handle Increased Traffic

### Notes & Guidance

Students will be doing XXX here, there are a few things to keep an eye on:

- Thing 1
- Thing 2

### Step By Step Walk-through

Now that you have a running instance of your app in GKE and exposed it to the internet, your website has become extremely popular. You need a way to scale your app to multiple instances so that you can handle the traffic. Learn to scale your application to up to three replicas.

Run the following command to scale your deployment up to three replicas:

```bash
kubectl scale deployment monolith --replicas=3
```

**Output:**

```bash
deployment.apps/monolith scaled
```

#### Verify scaled deployment

To verify that the Deployment was scaled successfully, run the following command:

```bash
kubectl get all
```

**Output:**

```bash
NAME                            READY   STATUS    RESTARTS   AGE
pod/monolith-7d8bc7bf68-2bxts   1/1     Running   0          36m
pod/monolith-7d8bc7bf68-7ds7q   1/1     Running   0          45s
pod/monolith-7d8bc7bf68-c5kxk   1/1     Running   0          45s

NAME                 TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)        AGE
service/kubernetes   ClusterIP      10.27.240.1    <none>         443/TCP        25h
service/monolith     LoadBalancer   10.27.253.64   XX.XX.XX.XX   80:32050/TCP   6m7s

NAME                       DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/monolith   3         3         3            3           61m

NAME                                  DESIRED   CURRENT   READY   AGE
replicaset.apps/monolith-7d8bc7bf68   3         3         3       61m
```

You should see three instances of your Pod running. Also, note that your Deployment and ReplicaSet now have a desired count of three.

## Challenge 5: Update and Release with Zero Downtime

### Notes & Guidance

Students will be doing XXX here, there are a few things to keep an eye on:

- Thing 1
- Thing 2

### Step By Step Walk-through

Your marketing team asked you to change your website's homepage. They think that it should be more informative by explaining what your company is and what you actually sell. In this section, you'll add some text to the homepage to make the marketing team happy. It looks like one of our developers already created the changes with the file name `index.js.new`. You can copy the file to `index.js` and your changes should be reflected. Follow the instructions below to make the appropriate changes.

Run the following commands, copy the updated file to the correct file name, and print its contents to verify the changes:

```bash
cd ~/monolith-to-microservices/react-app/src/pages/Home
mv index.js.new index.js
cat ~/monolith-to-microservices/react-app/src/pages/Home/index.js
```

The resulting code should look like this:

```bash
/*
Copyright 2019 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    https://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import React from "react";
import { makeStyles } from "@material-ui/core/styles";
import Paper from "@material-ui/core/Paper";
import Typography from "@material-ui/core/Typography";
const useStyles = makeStyles(theme => ({
  root: {
    flexGrow: 1
  },
  paper: {
    width: "800px",
    margin: "0 auto",
    padding: theme.spacing(3, 2)
  }
}));
export default function Home() {
  const classes = useStyles();
  return (
    <div className={classes.root}>
      <Paper className={classes.paper}>
        <Typography variant="h5">
          Fancy Fashion &amp; Style Online
        </Typography>
        <br />
        <Typography variant="body1">
          Tired of mainstream fashion ideas, popular trends and societal norms?
          This line of lifestyle products will help you catch up with the Fancy trend and express your personal style.
          Start shopping Fancy items now!
        </Typography>
      </Paper>
    </div>
  );
}
```

You updated the React components, but you need to build the React app to generate the static files. Run the following command to build the React app and copy it into the monolith public directory:

```bash
cd ~/monolith-to-microservices/react-app
npm run build:monolith
```

Now that your code is updated, you need to rebuild your Docker container and publish it to the Container Registry. You can use the same command as earlier, except this time, you'll update the version label!

Run the following command to trigger a new Cloud Build with an updated image version of 2.0.0:

```bash
cd ~/monolith-to-microservices/monolith

#Feel free to test your application
npm start

gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/monolith:2.0.0 .
```

Press `Control+C` (Windows or Mac) in the terminal window to stop the web server
process.

The changes are completed and the marketing team is happy with your updates. It's time to update the website without interruption to the users. Follow the instructions below to update your website.

GKE's rolling updates ensure that your application remains up and available even when the system replaces instances of your old container image with your new one across all the running replicas.

From the command line, you can tell Kubernetes that you want to update the image for your Deployment to a new version with the following command:

```bash
kubectl set image deployment/monolith monolith=gcr.io/${GOOGLE_CLOUD_PROJECT}/monolith:2.0.0
```

**Output:**

```bash
deployment.apps/monolith image updated
```

#### Verify Deployment

You can validate your Deployment update by running the following command:

```bash
kubectl get pods
```

Output:

```bash
NAME                        READY   STATUS              RESTARTS   AGE
monolith-584fbc994b-4hj68   1/1     Terminating         0          60m
monolith-584fbc994b-fpwdw   1/1     Running             0          60m
monolith-584fbc994b-xsk8s   1/1     Terminating         0          60m
monolith-75f4cf58d5-24cq8   1/1     Running             0          3s
monolith-75f4cf58d5-rfj8r   1/1     Running             0          5s
monolith-75f4cf58d5-xm44v   0/1     ContainerCreating   0          1s
```

You see three new Pods being created and your old pods being shut down. You can tell by the ages which are new and which are old. Eventually, you will only see three Pods again, which will be your three updated Pods.

To verify your changes, navigate to the external IP of the load balancer again and notice that your app has been updated.

Run the following command to list the services and view the IP address if you forgot it:

```bash
kubectl get services
```

Your website should display the text that you added to the homepage component!

![New Fancy Store](images/fancy-store-new.png)
