# Gaming on Google Cloud

## Introduction

Welcome to the coach's guide for Gaming on Google Cloud. Here you will find links to specific guidance for coaches for each of the challenges.

> **Note** If you are a gHacks participant, this is the answer guide. Don't cheat yourself by looking at this guide during the hack!

## Coach's Guides

- Challenge 1: Deploy the Agones Game Server Deployment Platform on Kubernetes
   - Deploy Agones, a library for hosting, running and scaling dedicated game servers on Kubernetes.
- Challenge 2: Deploy GameServers - Space Agon
   - Deploy a dedicated server to your Agones cluster and demonstrate its functionality.
- Challenge 3: Deploy and manage a Fleet
   - Deploy a Fleet of GameServers to your Agones cluster and manage it.
- Challenge 4: Deploy your own frontend web client and Service
   - Deploy your own web client to connect to your GameServers.
- Challenge 5: Matchmaking with Open Match
   - Implement OpenMatch and customize your matchmaking function.

## Google Cloud Requirements

This hack requires students to have access to Google Cloud project where they can create and consume Google Cloud resources. These requirements should be shared with a stakeholder in the organization that will be providing the Google Cloud project that will be used by the students.

- Participants will need the Owner role on their respective projects

## Suggested gHack Agenda

- Day 1
   - Challenge 1 (~1 hour)
   - Challenge 2 (~2 hours)
   - Challenge 3 (~1 hour)
   - Challenge 4 (~1 hour)
   - Challenge 5 (~2 hours)

## Challenge 1: Deploy the Agones Game Server Deployment Platform on Kubernetes

### Notes & Guidance

In this challenge, participants will learn how to deploy Agones, an open-source, multiplayer, dedicated game server built on Kubernetes, in the Google Cloud environment. They will set up a Kubernetes cluster, install Agones and Open Match, and deploy a simple game server that they can netcat to and send messages to that it will echo back.

1. **Create an Autopilot Cluster:** We will need a cluster to run Agones and Open Match. We are using Autopilot because it is both cost efficient and recommended for teams looking to reduce the overhead of cluster maintenance.
```
gcloud container clusters create-auto space-agon \
  --region=us-central1 \
  --release-channel=stable \
  --autoprovisioning-network-tags=game-server
```
2. **Create the Firewall Rule:** We will also need a firewall rule to enable direct access to the game servers will run via Agones:
```
gcloud compute firewall-rules create gke-game-server-firewall \
  --allow udp:7000-8000 \
  --target-tags game-server \
  --description "Firewall to allow game server tcp traffic"
```
3. **Install Agones:** Install Agones with helm (YAML has run into issues when testing). These instructions are found at https://agones.dev/site/docs/installation/install-agones/helm so learners should find them if they are reading the resources provided in the gHack doc:
```
helm repo add agones https://agones.dev/chart/stable
helm repo update
helm install my-release --namespace agones-system --create-namespace agones/agones
```
This installs all the required Custom Resource Definitions and the components required for Agones.

4. **Confirming Agones started successfully:** To confirm Agones is up and running, run the following command:
```
kubectl get pods --namespace agones-system
```
It should describe six pods created in the agones-system namespace, with no error messages or status. All this pods should be in a **RUNNING** state similar to this:
```
NAME                                 READY   STATUS    RESTARTS        AGE
agones-allocator-858c55d5f6-226z9    1/1     Running   0               5m41s
agones-allocator-858c55d5f6-9gkm6    1/1     Running   0               5m41s
agones-allocator-858c55d5f6-s6r5h    1/1     Running   1 (3m26s ago)   5m40s
agones-controller-5d9dd98857-7vct4   1/1     Running   0               5m41s
agones-controller-5d9dd98857-ps8gj   1/1     Running   0               5m40s
agones-extensions-d9b78446d-mt8vp    1/1     Running   2 (2m48s ago)   5m41s
agones-extensions-d9b78446d-n8czt    1/1     Running   0               5m39s
agones-ping-5bcdb75f97-mmqxg         1/1     Running   0               5m40s
agones-ping-5bcdb75f97-z2q97         1/1     Running   1 (3m9s ago)    5m41s
```
5. **Install OpenMatch:** We are going to install Open Match with helm since it gives us a look at what we are setting. First we set our variables and add the repo, then we actually install Open Match with helm:
```
export OM_NS=open-match
export OM_VER=1.8.1
helm repo add $OM_NS https://open-match.dev/chart/stable
helm repo update
helm install $OM_NS \
	--create-namespace --namespace $OM_NS $OM_NS/open-match \
	--version $OM_VER \
	--set open-match-customize.enabled=true \
	--set open-match-customize.evaluator.enabled=true \
	--set open-match-customize.evaluator.replicas=1 \
	--set open-match-override.enabled=true \
	--set open-match-core.swaggerui.enabled=false \
	--set global.kubernetes.horizontalPodAutoScaler.frontend.maxReplicas=1 \
	--set global.kubernetes.horizontalPodAutoScaler.backend.maxReplicas=1 \
	--set global.kubernetes.horizontalPodAutoScaler.query.minReplicas=1 \
	--set global.kubernetes.horizontalPodAutoScaler.query.maxReplicas=1 \
	--set global.kubernetes.horizontalPodAutoScaler.evaluator.maxReplicas=1 \
	--set query.replicas=1 \
	--set frontend.replicas=1 \
	--set backend.replicas=1 \
	--set redis.master.resources.requests.cpu=0.1 \
	--set redis.replica.replicaCount=0 \
	--set redis.metrics.enabled=false
```
You’ll get some warnings and `resource mapping not found` messages, but that won’t be a problem for this exercise.

This will install the Open Match core framework, and an evaluator (which we won’t be covering in this workshop). Participants can learn more about evaluators from the linked Learning Resource in the Student's Guide.

6. **Confirm Open Match started successfully:** To confirm that the installation was successful, execute this command:
```
kubectl get pods -n open-match
```
You should receive a similar response:
```
NAME                                       READY   STATUS    RESTARTS   AGE
open-match-backend-86c8c77d9f-wnz4v        1/1     Running   0          65s
open-match-evaluator-648667c6cc-gcrsn      1/1     Running   0          65s
open-match-frontend-5fb6f4bd7c-p8bcr       1/1     Running   0          65s
open-match-query-8c644d8f5-7qsqc           1/1     Running   0          65s
open-match-redis-master-0                  1/1     Running   0          64s
open-match-synchronizer-86d55f55d9-s7qq2   1/1     Running   0          64s
```
If there are pods that are running but not entering the ready state, give it a couple of minutes. Check the logs; if the issue involves a service that is running that can’t be found, try deleting the problematic pods to fix the issue. Otherwise, continue on with the other challenges and this issue should resolve itself by the time the learners get to it.

If Open Match needs to be uninstalled for some reason, that can be done with the following.
```
helm repo remove $OM_NS 
helm uninstall -n $OM_NS $OM_NS
kubectl delete namespace $OM_NS
```

- Autopilot will need to scale up resources throughout the gHack and will do so automatically. During this scale up time though, it will look like pods are stuck in a pending state and you'll see errors like `couldn't get resource list for metrics.k8s.io/v1beta1: the server is currently unable to handle the request`. These issues will fix themselves once the autoscaling is complete.
- Open Match can take 2 minutes to get into a ready state, or it can take 2 hours. This is a known issue and will sort itself out with time. Don't focus on trying to fix this.
the participants just need to be patient.
- For all other errors, refer to the [Agones Troubleshooting](https://agones.dev/site/docs/guides/troubleshooting/) guide to identify and resolve the issues. `kubectl describe` and `kubectl logs` on the pods that are having issues will help with answering most questions on what is going wrong.
- Verify that the necessary network configurations, such as firewall rules and load balancers, are correctly set up to allow traffic to reach the game server.
- Encourage participants to thoroughly read the Agones documentation to understand the installation process and configuration options.
- Advise participants to capture screenshots or logs of the deployment process and any errors encountered for future reference and troubleshooting.

Deploying Agones game servers on Kubernetes is an essential skill for building multiplayer game infrastructures in the Google Cloud environment. By successfully completing this challenge, participants have gained hands-on experience with setting up a GKE cluster, installing Agones, and deploying game servers. This experience will enhance their understanding of Kubernetes orchestration and enable them to effectively utilize Agones for managing multiplayer game deployments.

## Challenge 2: Deploy a frontend web client and Service

### Notes & Guidance

The Game Frontend serves as a layer that transfers players’ matchmaking requests from players’ Game Client to proto messages that Open Match can understand. The Game Frontend typically performs the following tasks:

- Fetches the player data from some backend storage (or Platform Services if required) and authenticates players.
- Submits the matchmaking requests to Open Match by creating a Ticket.
- Communicates the Assignment result back to the Game Client once Open Match found an Assignment for this Ticket.

1. **Clone the GitHub Repository:** Participants will be using prebuilt applications for their game servers, frontends, director, and matchmaking. They will work out of this directory for the entirety of the gHack:
```
git clone https://github.com/TheLanceLord/space-agon-ghack
cd space-agon-ghack
```
   > **Note** Cloud Shell files that one participant creates will not be accessible by the other participants. Participants will want to coordinate the sharing of completed files with each other throught this hack so they don't replicate work they've already done.

2. **Create an Artifact Registry repository:** Students can do this using the UI. If needed, the gcloud command is `gcloud artifacts repositories create "space-agon-ghack" --location=us-central1 --repository-format=docker`.

3. **Build and push the Docker image for the frontend web application:** This code is provided in the Student Guide.
```
docker build . -f Frontend.Dockerfile -t $REGISTRY/space-agon-frontend:0.1
docker push $REGISTRY/space-agon-frontend:0.1
```
4. **Write and apply the frontend.yaml:**
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      run: frontend
  template:
    metadata:
      labels:
        run: frontend
    spec:
      containers:
      - image: $GAR_REPOSITORY/space-agon-frontend:0.1 # this needs to be the full image path, using a variable won't work
        imagePullPolicy: Always
        name: frontend
        ports:
        - containerPort: 8080
          protocol: TCP
        resources:
          limits:
            cpu: 500m
            memory: 2Gi
          requests:
            cpu: 500m
            memory: 2Gi

---

apiVersion: v1
kind: Service
metadata:
  labels:
    run: frontend
  name: frontend
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    run: frontend
  type: LoadBalancer
```
Apply the frontend.yaml with `kubectl apply -f frontend.yaml`.

5. **Connect to the frontend application:** After applying the deployment configs, we have to wait a couple of minutes for the service to get an external address. Run the command `watch kubectl get service frontend` and wait for the EXTERNAL-IP to for the address to be allocated to the backing external Load Balancer. When the external IP is ready, connect to it by using your web browser to go to `http://<YOUR-FRONTEND-IP>`.

- When using a browser to view the frontend, it may stall on a loading screen. Refreshing the page will fix the issue.
- A common issue for participants with less GKE experience is to overlook the image path and use a path from a sample reference rather than the image that they built and pushed to Artifact Registry.
- Encourage Mac users with non-Intel chips to use Firefox to avoid a known issue with the frontend displaying rapidly flashing white boxes against a dark background.

By successfully completing this challenge, participants have gained hands-on experience with GKE and set themselves up to learn in the proceeding challenges how Agones works using its own custom resources in conjunction with default Kubernetes resources.

## Challenge 3: Deploy Dedicated Servers - Space Agon

### Notes & Guidance

Participants will need to build the images for this dedicated game server, and push it up to Artifact Registry (GAR) so that we can host these game servers images in our Kubernetes cluster. We will connect to these game servers via the frontend that was setup in the previous challenge.

1. **Build and push the Docker image for the dedicated game server:** This code is provided in the Student Guide. The dedicated game server code already has the Agones Game Server SDK integrated into it.
```
docker build . -f Dedicated.Dockerfile -t $REGISTRY/space-agon-dedicated:0.1
docker push $REGISTRY/space-agon-dedicated:0.1
```
2. **Write and apply the gameserver.yaml:** All of the needed parameter are provided in the skeleton gameserver.yaml file that is provided to the participants in both the GitHub code and the Student Guide. The completed gameserver.yaml should look like the following:
```
apiVersion: "agones.dev/v1"
kind: GameServer
metadata:
  name: "dedicated"
spec:
  ports:
    - name: default
      portPolicy: Dynamic
      containerPort: 2156
      protocol: TCP
  template:
    spec:
      containers:
        - name: dedicated
          image: $GAR_REPOSITORY/space-agon-dedicated:0.1 # this needs to be the full image path, using a variable won't work
          resources:
            requests:
              memory: "200Mi"
              cpu: "500m"
            limits:
              memory: "200Mi"
              cpu: "500m"
```
Apply the gameserver.yaml using `kubectl apply -f gameserver.yaml`.

This creates a GameServer record inside Kubernetes, which has also created a backing Pod to run our dedicated game server code in. Running `kubectl get pods` should show two gameserver pods running. This is because Agones injected the SDK sidecar for readiness and health checking of the Game Server.

3. **Update the firewall rule:** Challenge 1 had the participants setup a firewall rule allowing UDP traffic in order to support the simple game server test. Space Agon uses TCP so participants will need to update their firewall rule to allow it:
```
gcloud compute firewall-rules update gke-game-server-firewall \
  --allow tcp:7000-8000,udp:7000-8000
```
4. **Connect to the dedicated game server:** Verify that the game server is ready by running `kubectl get gameserver` or `kubectl get gs` and note the IP address and port. Connect to the game server by navigating to `http://<YOUR-FRONTEND-IP>`, and then clicking the **Connect to Server** button and providing the GameServer's IP address and port.

- Participants will have most likely missed that they don't have the appropriate firewall rule to allow them to connect to their game server. They will want to enable firewall logging to get more details on what is happening, or they can attempt to ping the ip address and port and see that they fail to get a response.

By successfully completing this challenge, participants have learned how to deploy a dedicated gaming server using Agones.

## Challenge 4: Deploy and manage a Fleet

### Notes & Guidance

In production, you will usually want a warm fleet of Ready GameServers, waiting for players to come play on them -- so let’s set that up with an Agones Fleet!

1. **Write and apply the fleet.yaml:** The complete fleet.yaml should look like the following:
```
apiVersion: agones.dev/v1
kind: Fleet
metadata:
  name: dedicated
spec:
  replicas: 2
  template:
    spec:
      ports:
      - containerPort: 2156
        name: default
        portPolicy: Dynamic
        protocol: TCP
      template:
        spec:
          containers:
          - image: $GAR_REPOSITORY/space-agon-dedicated:0.1 # this needs to be the full image path, using a variable won't work
            name: dedicated
            resources:
              limits:
                cpu: 500m
                memory: 200Mi
              requests:
                cpu: 500m
                memory: 200Mi
```
Apply the fleet.yaml using `kubectl apply -f fleet.yaml`.

2. **Check the Fleet status:** Running `kubectl get fleet` should return code similar to the following:
```
NAME         SCHEDULING   DESIRED   CURRENT   ALLOCATED   READY     AGE
dedicated    Packed       2         2         0           2         9m
```
   > **Note** The participants will likely have named their Fleet something other than "dedicated". This is fine for now, and will be a learning opportunity in the next challenge.

3. **Scale the Fleet up to 5 replicas:** The Fleet can be scaled up by running `kubectl scale fleet dedicated --replicas=5`. Afterwards run either `kubectl get fleet` or `kubectl get gs` or `kubectl get gameservers` to verify that the new servers are **Ready**.

4. **Write and create the allocation.yaml:** The complete allocation.yaml file should look like the following (the label value may be different if they didn't name their Fleet "dedicated"):
```
apiVersion: "allocation.agones.dev/v1"
kind: GameServerAllocation
spec:
  required:
    matchLabels:
      agones.dev/fleet: dedicated
```
and you can create the GameServerAllocation by running `kubectl create -f myallocation.yaml -o yaml`. The `-o yaml` option isn't required, but it does return yaml formatted output that tells us some things. If you look at the status section, the state value will tell if a GameServer was allocated or not. If a GameServer could not be found, this will be set to UnAllocated. If we see that the status.state value was set to Allocated, this means a GameServer has been successfully allocated out of the Fleet and that players can now connect to it.

You can also see various immutable details of the GameServer in the status - the address, ports and the name of the GameServer, in case more details need to be retrieved.

5. **Get the IP address and port of the allocated GameServer and play the game:** You will want to connect to the allocated GameServer. To do this, list of all the current GameServers and their Status.State by using running `kubectl get gameservers`, and select the IP address and port of the server that is in the Allocated state. Example below:
```
NAME                    STATE       ADDRESS   PORT   NODE       AGE
dedicated-kdgk6-c9tqz   Ready       10.9.8.7  7136   agones     52m
dedicated-kdgk6-g8fhq   Allocated   10.9.8.7  7148   agones     53m
dedicated-kdgk6-p8wnl   Ready       10.9.8.7  7453   agones     52m
dedicated-kdgk6-t6bwp   Ready       10.9.8.7  7228   agones     53m
dedicated-kdgk6-wkb7b   Ready       10.9.8.7  7226   agones     52m
```
Connect to `http://<YOUR-FRONTEND-IP>` and then click **Connect to Server** and providing the GameServers IP address and port.

- Participants will have most likely missed that they don't have the appropriate firewall rule to allow them to connect to their game server. They will want to enable firewall logging to get more details on what is happening, or they can attempt to ping the ip address and port and see that they fail to get a response.

By successfully completing this challenge, participants have learned how to create a Fleet and understand the role of GameServerAllocation.

## Challenge 5: Matchmaking with Open Match

### Notes & Guidance

This challenge is going to be a chance for the participants to demonstrate their lessons learned during the previous challenges, as well as get practice in modifying an existing matchmaking function. Given the time constraints of this training, we can't expect participants to write a matchmaking function from scratch at integrated it with the frontend, which is why all of that has been taken care of for them.

1. **Build and push the Docker image for the matchmaking function:** This code is provided in the Student Guide.
```
docker build . -f Mmf.Dockerfile -t $REGISTRY/space-agon-mmf:0.1
docker push $REGISTRY/space-agon-mmf:0.1
```
2. **Write and apply the mmf.yaml:** Like in the previous challenges, participants will need to create containers in their cluster. The completed mmf.yaml should look like the following:
```
apiVersion: v1
kind: Service
metadata:
  name: mmf
  labels:
    run: mmf
spec:
  ports:
  - port: 50502
    protocol: TCP
    targetPort: 50502
  selector:
    run: mmf

---

apiVersion: apps/v1
kind: Deployment
metadata:
  name: mmf
spec:
  replicas: 2
  selector:
    matchLabels:
      run: mmf
  template:
    metadata:
      labels:
        run: mmf
    spec:
      containers:
      - image: us-central1-docker.pkg.dev/qwiklabs-gcp-01-dae9145d7029/space-agon/space-agon-mmf:0.1
        imagePullPolicy: Always
        name: mmf
        ports:
        - containerPort: 50502
          protocol: TCP
```
Apply the mmf.yaml using `kubectl apply -f mmf.yaml`.

3. **Build and push the Docker image for the Director:** This code is provided in the Student Guide.
```
docker build . -f Director.Dockerfile -t $REGISTRY/space-agon-director:0.1
docker push $REGISTRY/space-agon-director:0.1
```
4. **Add the Director deployment to the director.yaml:** The complete deployment should look like the following:
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: director
spec:
  replicas: 1
  selector:
    matchLabels:
      run: director
  template:
    metadata:
      labels:
        run: director
    spec:
      containers:
      - image: $GAR_REPOSITORY/space-agon-director:0.1 # this needs to be the full image path, using a variable won't work
        imagePullPolicy: Always
        name: director
      serviceAccount: fleet-allocator

---
```
5. **Append a Role for Fleets and GameServerAllocations to the director.yaml:** Because the Director calls the Kubernetes API to interact with Agones, it needs a service account for the Director Deployment that has the explicit permissions to access and manipulate the Custom Resource Definitions that Agones provides - in this case Fleets and GameServerAllocations. The code to be appended should like the following:
```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  labels:
    app: fleet-allocator
  name: fleet-allocator
rules:
- apiGroups:
  - ""
  resources:
  - events
  verbs:
  - create
- apiGroups:
  - allocation.agones.dev
  resources:
  - gameserverallocations
  verbs:
  - create
- apiGroups:
  - agones.dev
  resources:
  - fleets
  verbs:
  - get

---
```
6. **Append a ServiceAccount to the director.yaml:** We will need a ServiceAccount to be bound to the Role. The code to be appended should look like the following:
```
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app: fleet-allocator
  name: fleet-allocator

---
```
7. **Bind the Role and ServiceAccount in the director.yaml and then apply:** Now we actually bind the ServiceAccount and Role. The code to be appended should look like the following:
```
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    app: fleet-allocator
  name: fleet-allocator
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: fleet-allocator
subjects:
- kind: ServiceAccount
  name: fleet-allocator
```
Apply the director.yaml using `kubectl apply -f director.yaml`.

8. **Play Space Agon:** Connect to `http://<YOUR-FRONTEND-IP>` and then click **Find Server** to verify that the prebuilt matchmaking function is working.

9. **Update the Matchmaking Function to support the entire team playing the game at the same time:** Participants will need to navigate in their cloned GitHub repository to mmf > mmf.go. In the mmf.go file, they will need to update lines 103 - 113 to allow the whole team to connect. The below is an example for a team of 5, plus 1 coach (6 total):
```
	for i := 0; i+5 < len(tickets); i += 6 {
		proposal := &pb.Match{
			MatchId:       fmt.Sprintf("profile-%s-time-%s-num-%d", profile.Name, t, i/6),
			MatchProfile:  profile.Name,
			MatchFunction: matchName,
			Tickets: []*pb.Ticket{
				tickets[i], tickets[i+1], tickets[i+2], tickets[i+3], tickets[i+4], tickets[i+5],
			},
		}
		matches = append(matches, proposal)
	}
```
10. **Build and push the Docker image for the custom matchmaking function and reapply the mmf.yaml:** With the changes made to the matchmaking function, we will need a new image.
```
docker build . -f Mmf.Dockerfile -t $REGISTRY/space-agon-mmf:0.2
docker push $REGISTRY/space-agon-mmf:0.2
```
If the participants created a new tag, then they will need to update the image in their mmf.yaml with it before applying. Otherwise, they will likely need to delete the old Matchmaking Function deployment before running `kubectl apply -f mmf.yaml`.

11. **Play Space Agon:** Connect to `http://<YOUR-FRONTEND-IP>` and then click **Find Server** to verify that the customized matchmaking function is working.

- It is likely the students named their fleet something other than dedicated, which is a problem because the Director has been built to look for a fleet labeled dedicated to allocate servers from. Here is how to help the students troubleshoot the issue:
   1. Participants open 2 browsers to the game, they each hang on the looking for a match screen.
   2. Run `kubectl get pods`.
   3. Run `kubectl logs <director pod>`.
   4. In the middle of all of the lines like "Created and assigned 0 matches" you should see "failed to allocate game server.".
   5. Search for the aforementioned line in the code in the https://github.com/TheLanceLord/space-agon-ghack GitHub and see that on line 114 it's matching to a specific fleet name "dedicated".
   6. Updated the fleet name to dedicated, reapply the fleet.yaml with `kubectl apply -f fleet.yaml`, and verify that the fix worked.

By successfully completing this challenge, participants have learned the different components in standing up Open Match in their cluster, as well as some basics on customizing the Matchmaking function.