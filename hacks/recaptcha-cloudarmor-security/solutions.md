# Security with reCAPTCHA and Cloud Armor

## Introduction
Welcome to the coach's guide for the Security with reCAPTCHA and Cloud Armor gHack. Here you will find links to specific guidance for coaches for each of the challenges.

## Coach's Guides
- Setting Up the Environment
   - Before starting to hack, students will need to set up a few things.
   - They will run the instructions on our [Environment Setup](../../faq/howto-setup-environment.md) page.
- Challenge 1: Create Managed Instance Groups
   - Use managed instance groups to create an HTTP Load Balancer backend.
- Challenge 2: Setup Your HTTP Load Balancer
   - Configure the HTTP Load Balancer to send traffic to your backend.
- Challenge 3: Deploy a reCAPTCHA Token and Challenge Page
   - Implement reCAPTCHA on a website's landing page. 
- Challenge 4: Configure Bot Management
   - Use Cloud Armor bot management rules to allow, deny and redirect requests based on the reCAPTCHA score.

## Challenge 1: Create Managed Instance Groups

### Notes & Guidance
Students will creating managed instance groups here, so there are a few things to keep an eye on:

- They might not know that the Startup script has to be copy and pasted verbatim.

### Step By Step Walk-through

#### Configure the instance templates
1. In the Cloud Console, navigate to **Navigation menu > Compute Engine > Instance templates**, and then click **Create instance template**.
1. For **Name**, type **lb-backend-template**.
1. For **Series**, select **N1**.
1. Click on the **Advanced options** section to open it.

    ![MIG Startup Script](images/mig-startup-script.png)

1. Click on the **Networking** section, add the network tags: **allow-health-check** (and press tab or enter)
1. Set the following values and leave all other values at their defaults:

    |Property|Value|
    |--|--|
    |Network|ghack|
    |Subnet|ghack (us-central1)|
    |Network tags|allow-health-check|
    
    > The network tag **allow-health-check** ensures that the HTTP Health Check and SSH firewall rules apply to these instances.

    > **Note** Make sure to type a space or press tab after typing the tag name, otherwise it might not get set.

1. Go to the **Management** section and insert the following script into the **Startup script** field:

    ```bash
    #! /bin/bash
    sudo apt-get update
    sudo apt-get install apache2 unzip -y
    sudo a2ensite default-ssl
    sudo a2enmod ssl
    export vm_hostname="$(hostname)"
    sudo echo "Page served from: $vm_hostname" | \
    sudo tee /var/www/html/index.html
    ```

1. Click **Create**.
1. Wait for the instance template to be created.

#### Create the managed instance group
1. Still in the **Compute Engine** page, click **Instance groups** in the left menu.

    ![Create MIG](images/mig-create-menu.png)

1. Click **Create instance group**. Select **New managed instance group (stateless)**.
1. Set the following values, leave all other values at their defaults:

    |Property|Value|
    |--|--|
    |Name|lb-backend-instance-group|
    |Location|Single zone|
    |Region|us-central1|
    |Zone|us-central1-a|
    |Instance template|lb-backend-template|
    |Autoscaling|Don't autoscale|
    |Number of instances|1|

1. Click **Create**

#### Add a named port to the instance group
1. For your instance group, use this command to define an HTTP service and map a port name to the relevant port. The load balancing service forwards traffic to the named port.

    ```bash
    gcloud compute instance-groups set-named-ports lb-backend-instance-group \
        --named-ports http:80 \
        --zone us-central1-a
    ```

## Challenge 2: Setup Your HTTP Load Balancer

### Notes & Guidance
- Remember that the HTTP Load Balancer can take up to 15 minutes to provision, make sure the students are patient.
- Sometimes students get hung up on setting up the health checks properly.

### Step By Step Walk-through
#### Start the configuration
1. In the Cloud Console, click **Navigation menu** > click **Network Services** > **Load balancing**, and then click **Create load balancer**.
1. Under **HTTP(S) Load Balancing**, click on **Start configuration**.

    ![Start Configuration](images/lb-start-config.png)

1. Select **From Internet to my VMs** and select **Global HTTP(S) Load Balancer (classic)** then click **Continue**.
1. Set the **Load Balancer name** to *http-lb*.

#### Configure the frontend
The host and path rules determine how your traffic will be directed. For example, you could direct video traffic to one backend and static traffic to another backend. However, you are not configuring the Host and path rules in this hack.

1. Click on **Frontend configuration**.
1. Specify the following, leaving all other values at their defaults:

    |Property|Value|
    |--|--|
    |Protocol|HTTP|
    |IP Version|IPv4|
    |IP Address|Ephemeral|
    |Port|80|

1. Click **Done**.

#### Configure the backend
Backend services direct incoming traffic to one or more attached backends. Each backend is composed of an instance group and additional serving capacity metadata.

1. Click on **Backend configuration**.
1. For **Backend services & backend buckets**, click **Create a backend service**.
1. Set the following values, leave all other values at their defaults:

    |Property|Value|
    |--|--|
    |Name|lb-backend|
    |Protocol|HTTP|
    |Named Port|http|
    |Instance Group|lb-backend-instance-group|
    |Port Numbers|80|

1. Click **Done**.
1. For **Health Check**, select **Create a health check**.

    ![Create a Health Check](images/lb-create-health-check.png)

1. Set the following values, leave all other values at their defaults:

    |Property|Value|
    |--|--|
    |Name|http-health-check|
    |Protocol|TCP|
    |Port|80|

    > Health checks determine which instances receive new connections. This HTTP health check polls instances every 5 seconds, waits up to 5 seconds for a response and treats 2 successful or 2 failed attempts as healthy or unhealthy, respectively.

    ![Health Criteria](images/lb-health-criteria.png)

1. Click **Save**.
1. Check the **Enable Logging** box.
1. Set the **Sample Rate** to 1:

    ![Sample Rate](images/lb-sample-rate.png)

1. Click Create to create the backend service.

    ![Create Backend](images/lb-create-backend.png)

#### Review and create the HTTP Load Balancer
1. Click on **Review and finalize**.

    ![Review and Finalize](images/lb-review-finalize.png)

1. Review the **Backend services** and **Frontend**.
1. Click on **Create**.
1. Wait for the load balancer to be created.
1. Click on the name of the load balancer: **http-lb**.
1. Note the IPv4 address of the load balancer for the next task. We will refer to it as **[LB_IP_v4]**.

#### Test the HTTP Load Balancer
Now that you created the HTTP Load Balancer for your backends, verify that traffic is forwarded to the backend service. To test IPv4 access to the HTTP Load Balancer, open a new tab in your browser and navigate to **http://[LB_IP_v4]**. Make sure to replace **[LB_IP_v4]** with the IPv4 address of the load balancer.

You should see a simple webpage saying:

```
Page served from: { name of your VM }
```

> **Note** It might take up to 15 minutes to access the HTTP Load Balancer. In the meantime, you might get a 404 or 502 error. Keep trying until you see the page load.

## Challenge 3: Deploy a reCAPTCHA Token and Challenge Page

### Notes & Guidance
- Before starting make sure to give them another overview of how reCAPTCHA works and how it uses different levels of scoring.
- Updating the html files can be a little tricky, keep an eye on them.

### Step By Step Walk-through
#### Create reCAPTCHA session token and WAF challenge-page site key
The reCAPTCHA JavaScript sets a reCAPTCHA session-token as a cookie on the end-user's browser after the assessment. The end-user's browser attaches the cookie and refreshes the cookie as long as the reCAPTCHA JavaScript remains active.

1. Create the reCAPTCHA session token site key and enable the WAF feature for the key. We will also be setting the WAF service to Cloud Armor to enable the Cloud Armor integration.

    ```bash
    gcloud recaptcha keys create --display-name=test-key-name \
        --web --allow-all-domains --integration-type=score --testing-score=0.5 \
        --waf-feature=session-token --waf-service=ca
    ```

    > **Note** We are using the integration type **score** which will be leveraged in the Cloud Armor policy. You can alternatively use **checkbox** and **invisible**.

    > **Note** We are also setting a **testing score** when creating the key to validate that the bot management policies we create with Cloud Armor are working as intended. Replicating bot traffic is not easy and hence, this is a good way to test the feature.

1. Output of the above command, gives you the key created. Make a note of it as we will add it to your web site in the next step.
1. Create the reCAPTCHA WAF challenge-page site key and enable the WAF feature for the key. You can use the reCAPTCHA challenge page feature to redirect incoming requests to reCAPTCHA Enterprise to determine whether each request is potentially fraudulent or legitimate. We will later associate this key with the Cloud Armor security policy to enable the manual challenge. We will refer to this key as **CHALLENGE-PAGE-KEY** in the later steps.

    ```bash
    gcloud recaptcha keys create --display-name=challenge-page-key \
        --web --allow-all-domains --integration-type=INVISIBLE \
        --waf-feature=challenge-page --waf-service=ca
    ```

1. Navigate to **Navigation menu > Security > reCAPTCHA Enterprise**. You should see the keys you created under Enterprise Keys:

    ![Enterprise Keys](images/recaptcha-main.png)

#### Implement reCAPTCHA session token site key
1. Navigate to **Navigation menu > Compute Engine > VM Instances**. Locate the VM in your instance group and make note of its name, eg: `lb-backend-instance-group-f6z7`

    ![Enterprise Keys](images/recaptcha-vm-login.png)

1. Use `gcloud compute scp` from the Cloud Shell and upload `student-files.zip` (it should've already been uploaded to the Cloud Shell from the Google Space's Files tab) to the VM.

    ```bash
    gcloud compute scp student-files.zip lb-backend-instance-group-f6z7:~ --zone us-central1-a
    ```

1. SSH to the VM and unzip the file into the root html folder:
    
    ```bash
    gcloud compute ssh lb-backend-instance-group-f6z7 --zone us-central1-a
    ```
    ```bash
    sudo unzip -o -d /var/www/html student-files.zip 
    ```

1. Update `index.html` and embed the reCAPTCHA session token site key. The session token site key is set in the `HEAD` section of your landing page as below: 

    ```html
    <script src="https://www.google.com/recaptcha/enterprise.js?render=<REPLACE_TOKEN_HERE>&waf=session" async defer></script>
    ```

1. Validate that you are able to access all the webpages by opening them in your browser. Make sure to replace **[LB_IP_v4]** with the IPv4 address of the load balancer.
    - Open ***http://[LB_IP_v4]/index.html***. You will be able to verify that the reCAPTCHA implementation is working when you see "protected by reCAPTCHA" at the bottom right corner of the page:
        
        ![Protect Logo](images/recaptcha-protect-logo.png)

    - Click into each of the links:

        ![Main Page](images/recaptcha-site-mainpage.png)

    - Validate you are able to access all the pages.

        ![Good](images/recaptcha-site-goodscore.png)
        ![Median](images/recaptcha-site-medianscore.png)
        ![Bad](images/recaptcha-site-badscore.png)

## Challenge 4: Configure Bot Management

### Notes & Guidance
- There are a lot of gcloud command line calls that need to be discovered here, make sure they're reading the linked documentation.
- They have to get the MQL statement exactly right, try to hold their hand through that.

### Step By Step Walk-through
#### Create Cloud Armor security policy rules for Bot Management
In this section, you will use Cloud Armor bot management rules to allow, deny and redirect requests based on the reCAPTCHA score. Remember that when you created the session token site key, you set a testing score of 0.5.

1. In Cloud Shell, create a security policy via gcloud:

    ```bash
    gcloud compute security-policies create recaptcha-policy \
        --description "policy for bot management"
    ```
1. To use reCAPTCHA Enterprise manual challenge to distinguish between human and automated clients, associate the reCAPTCHA WAF challenge site key we created for manual challenge with the security policy. Replace "CHALLENGE-PAGE-KEY" with the key we created:

    ```bash
    gcloud compute security-policies update recaptcha-policy \
        --recaptcha-redirect-site-key "CHALLENGE-PAGE-KEY"
    ```

1. Add a bot management rule to allow traffic if the url path matches good-score.html and has a score greater than 0.4:

    ```bash
    gcloud compute security-policies rules create 2000 \
        --security-policy recaptcha-policy \
        --expression "request.path.matches('good-score.html') && token.recaptcha_session.score > 0.4" \
        --action allow
    ```

1. Add a bot management rule to deny traffic if the url path matches bad-score.html and has a score less than 0.6: 

    ```bash
    gcloud compute security-policies rules create 3000 \
        --security-policy recaptcha-policy \
        --expression "request.path.matches('bad-score.html') && token.recaptcha_session.score < 0.6" \
        --action "deny-403"
    ```

1. Add a bot management rule to redirect traffic to Google reCAPTCHA if the url path matches median-score.html and has a score equal to 0.5:

    ```bash
    gcloud compute security-policies rules create 1000 \
        --security-policy recaptcha-policy \
        --expression "request.path.matches('median-score.html') && token.recaptcha_session.score == 0.5" \
        --action redirect \
        --redirect-type google-recaptcha
    ```

1. Attach the security policy to the backend service lb-backend:

    ```bash
    gcloud compute backend-services update lb-backend \
        --global --security-policy=recaptcha-policy 
    ```

1. In the Console, navigate to **Navigation menu > Network Security > Cloud Armor**.

1. Click **recaptcha-policy**. Your policy should resemble the following:

    ![recaptcha rules](images/armor-rules.png)

#### Validate Bot Management with Cloud Armor

1. Open up a browser and go to ```http://{LoadBalancer_IP_Here}/index.html```. Click on the movie ***Brooklyn Dreams***. Verify you are allowed through.

    ![armor good score](images/recaptcha-site-goodscore.png)

1. Open a new window in Incognito mode to ensure we have a new session and go to ```http://{LoadBalancer_IP_Here}/index.html```. Click on the movie ***Thorned***. Verify you receive a HTTP 403 error.

    ![armor bad score](images/armor-bad-score.png)

1. Open another new window in Incognito mode to ensure we have a new session and go to ```http://{LoadBalancer_IP_Here}/index.html```. Click on the movie ***La Cucina in Crisis***. Verify you see the redirection to Google reCAPTCHA and the manual challenge page.

    > **Note** Depending on your Internet usage, reCAPTCHA might already think you're trusted and will not display the manual challenge.

    ![armor recaptcha click check](images/armor-click-check.png)

#### Verify Cloud Armor logs

Explore the security policy logs to validate bot management worked as expected.

1. In the Console, navigate to **Navigation menu > Network Security > Cloud Armor**.

1. Click **recaptcha-policy**

1. Click **Logs**

    ![armor logs](images/armor-logs.png)

1. Click **View policy logs**

1. Below is the MQL(monitoring query language) query, you can copy and paste into the query editor: 

    ```sql
    resource.type:(http_load_balancer) AND jsonPayload.enforcedSecurityPolicy.name:(recaptcha-policy)
    ```

1. Now click Run Query.

1. Look for a log entry in Query results where the request is for ```http://{LoadBalancer_IP_Here}/good-score.html```. Expand jsonPayload. Expand enforcedSecurityPolicy.

    ![armor good results](images/armor-good-results.png)

1. Repeat the same for ```http://{LoadBalancer_IP_Here}/bad-score.html``` and ```http://{LoadBalancer_IP_Here}/median-score.html```

    ![armor bad results](images/armor-bad-results.png)

    ![armor median results](images/armor-median-results.png)

Notice that the configuredAction is set to **ALLOW, DENY or GOOGLE_RECAPTCHA** with the name **recaptcha-policy**.

> **Note** Cloud Armor security policies create logs that can be explored to determine when traffic is denied and when it is allowed, along with the source of the traffic.