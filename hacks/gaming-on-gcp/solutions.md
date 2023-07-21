# Gaming in GCP: Have Fun!

## Introduction

Welcome to the coach's guide for Gaming in GCP. Here you will find links to specific guidance for coaches for each of the challenges.

> **Note** If you are a gHacks participant, this is the answer guide. Don't cheat yourself by looking at this guide during the hack!

## Coach's Guides

- Challenge 1: Agones Game Servers on Kubernetes
   - Deploy Agones, an open-source, multiplayer, dedicated game-server built on Kubernetes in the Google Cloud environment.
- Challenge 2: Dynamic Game Matching with Open Match
   - Implement dynamic game matching using Open Match in the Google Cloud environment.
- Challenge 3: Game State and Activity Management with Spanner
   - leverage Google Cloud Spanner as the game state and activity store in the Google Cloud environment.
- Challenge 4: Player Churn Prediction with BigQuery
   - Leverage Google BigQuery to predict player churn in your multiplayer gaming platform in the Google Cloud environment.

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

## Challenge 1: Agones Game Servers on Kubernetes

### Notes & Guidance

In this challenge, participants will learn how to deploy Agones, an open-source, multiplayer, dedicated game server built on Kubernetes, in the Google Cloud environment. They will set up a Kubernetes cluster, install Agones, and deploy a game server.

### Objectives

- Set up a Google Kubernetes Engine (GKE) cluster.
- Install Agones on the Kubernetes cluster.
- Create a game server deployment using Agones.
- Validate the successful deployment and accessibility of the game server.

### Prerequisites

- Understanding of Kubernetes concepts and architecture.
- Familiarity with Google Cloud Platform (GCP) and its console or command-line tools.
- Basic knowledge of YAML configuration files.

### Materials

- Access to GCP Console or command-line tools.
- Agones documentation: [https://agones.dev/](https://agones.dev/)
- GKE documentation: [https://cloud.google.com/kubernetes-engine](https://cloud.google.com/kubernetes-engine)

### Suggested Steps

1. **Setting up the GKE Cluster:** Participants should create a GKE cluster using the GCP Console or command-line tools. They need to specify the desired configuration options such as cluster name, number of nodes, machine type, and region. Participants should ensure the cluster is successfully provisioned and accessible.

2. **Installing Agones:** Participants should refer to the Agones documentation to install Agones on the GKE cluster. They need to follow the provided instructions to set up the necessary components and configurations for Agones. Participants should verify that Agones is installed and running correctly on the cluster.

3. **Creating Game Server Deployment:** Participants should define a basic game server deployment using Agones configuration. They need to create a YAML file specifying the game server image, ports, and any other required parameters. Participants should apply the configuration to the cluster and verify that the game server deployment is successfully created.

4. **Testing the Deployment:** Participants should test the game server deployment to ensure it meets the success criteria. They need to check the status of the pods and services created by Agones, ensuring that the game server is running and accessible. Participants should perform any necessary troubleshooting to resolve any issues that may arise.

5. **Validation and Success Criteria:** Participants should validate the successful deployment of Agones and the game server. They need to ensure that Agones is installed on the Kubernetes cluster without errors. Additionally, they should confirm that the game server deployment is accessible and functioning as expected.

6. **Documentation and Presentation:** Participants should document the steps they followed, any challenges they encountered, and the solutions they applied. They should prepare a presentation summarizing their approach, including the GKE cluster setup, Agones installation, game server deployment, and successful validation.

### Troubleshooting Tips

- If any errors occur during the installation or deployment process, refer to the Agones documentation and troubleshooting guides to identify and resolve the issues.
- Check the logs of Agones components and game server pods for any error messages that may indicate misconfigurations or other problems.
- Verify that the necessary network configurations, such as firewall rules and load balancers, are correctly set up to allow traffic to reach the game server.

### Recommendations

- Encourage participants to thoroughly read the Agones documentation to understand the installation process and configuration options.
- Remind participants to follow best practices for setting up a GKE cluster, such as selecting an appropriate machine type and specifying resource limits.
- Suggest participants test the game server deployment thoroughly by connecting to it and verifying its functionality.
- Advise participants to capture screenshots or logs of the deployment process and any errors encountered for future reference and troubleshooting.

### Conclusion

Deploying Agones game servers on Kubernetes is an essential skill for building multiplayer game infrastructures in the Google Cloud environment. By successfully completing this challenge, participants have gained hands-on experience with setting up a GKE cluster, installing Agones, and deploying game servers. This experience will enhance their understanding of Kubernetes orchestration and enable them to effectively utilize Agones for managing multiplayer game deployments.

## Challenge 2: Dynamic Game Matching with Open Match

### Notes & Guidance

In this challenge, participants will leverage Open Match, an open-source matchmaking framework, to implement game matching functionality for their gaming application. Open Match simplifies the process of creating a matchmaking system by providing a scalable and flexible solution that can be integrated into various game environments.

Participants will be required to set up and configure Open Match, define matchmaking rules, and integrate it into their gaming application to facilitate the matching of players based on skill level, latency, or other desired criteria. They will need to test and validate the matchmaking system to ensure it is functioning correctly and efficiently.

### Objectives

- Set up and configure Open Match for game matching.
- Define matchmaking rules and criteria based on skill level, latency, or other desired parameters.
- Integrate Open Match into the gaming application to enable player matchmaking.
- Test and validate the matchmaking system to ensure accurate and efficient player matching.

### Prerequisites

- Familiarity with game development concepts and multiplayer game architecture.
- Basic understanding of networking and server-client communication in game development.
- Knowledge of Kubernetes and containerization concepts is beneficial but not mandatory.

### Materials

- [Open Match Documentation](https://open-match.dev/site/docs/)
- [Open Match GitHub Repository](https://github.com/googleforgames/open-match)
- [Open Match Get Started](https://open-match.dev/site/docs/getting-started/)
- [Open Match Tutorials](https://open-match.dev/site/docs/tutorials/matchmaker101/)
- [Open Match Guides](https://open-match.dev/site/docs/guides/matchmaker/)

### Suggested Steps

1. **Research and Familiarization:** Participants should begin by researching Open Match and understanding its core concepts, architecture, and features. They should review the documentation, tutorials, and examples provided to gain a solid understanding of how Open Match works.

2. **Setup and Configuration:** Participants need to set up and configure Open Match in their development environment. They should follow the installation instructions provided in the Open Match documentation. This may involve deploying Open Match components on Kubernetes or a similar container orchestration platform.

3. **Matchmaking Rules Definition:** Participants should define the matchmaking rules and criteria based on the specific requirements of their gaming application. They should consider factors such as skill level, player preferences, latency, and any other relevant parameters. The matchmaking rules should be implemented using the Open Match APIs or configuration files.

4. **Integration with Gaming Application:** Participants should integrate Open Match into their gaming application. They need to modify the game client and server code to communicate with Open Match for player matchmaking. This may involve making API calls, handling matchmaking events, and updating game states based on the results of the matchmaking process.

5. **Testing and Validation:** Participants should thoroughly test and validate the matchmaking system. They should verify that players are correctly matched according to the defined rules and criteria. It is essential to test various scenarios, including different player skill levels, high player loads, and potential edge cases.

6. **Optimization and Fine-tuning:** Participants should optimize the matchmaking system based on performance and user feedback. They may need to adjust the matchmaking rules, algorithms, or infrastructure configurations to improve the overall player matching experience.

7. **Documentation and Presentation:** Participants should document their implementation process, challenges faced, and solutions applied. They should prepare a presentation summarizing their approach, results, and any insights gained from implementing Open Match for game matching.

### Tips and Recommendations

- Encourage participants to leverage the Open Match community and resources, such as forums, GitHub issues, and Slack channels, for support and guidance.
- Remind participants to thoroughly test and validate their matchmaking system to ensure it performs well under different scenarios and loads.
- Emphasize the importance of documenting the implementation process, challenges faced, and lessons learned for future reference.

### Potential Challenges and Solutions

- **Complexity of Open Match:** Participants may have faced challenges in understanding the complex architecture and concepts of Open Match. Encourage them to spend time studying the documentation and examples, and seek help from the Open Match community for clarification and guidance.

- **Integration with Gaming Application:** Integrating Open Match into an existing gaming application can be a significant challenge. Participants may encounter compatibility issues or conflicts with the existing game codebase. Encourage them to carefully review the integration steps provided in the Open Match documentation and seek assistance from the community if needed.

- **Optimization and Performance:** Achieving optimal performance and scalability in the matchmaking system can be challenging, especially under high player loads. Participants should focus on load testing and profiling their system to identify bottlenecks and areas for optimization. They can experiment with different matchmaking algorithms and infrastructure configurations to improve performance.

### Conclusion

Implementing Open Match for game matching provides participants with a robust and scalable matchmaking solution for their gaming application. By successfully completing this challenge, participants have gained hands-on experience with Open Match and enhanced their skills in building multiplayer game environments.

## Challenge 3: Game State and Activity Management with Spanner

### Notes & Guidance

In this challenge, participants will leverage Google Cloud Spanner as the game state and activity store for their gaming application. Cloud Spanner is a fully managed, highly available, and globally distributed relational database service that provides strong consistency and horizontal scalability.

Participants will be required to design and implement a schema for storing game state and player activity using Cloud Spanner. They will need to create tables, define appropriate indexes, and establish relationships between entities. Additionally, participants will need to integrate Cloud Spanner into their gaming application, allowing for real-time updates and retrieval of game state and activity data.

### Objectives

- Design a schema for storing game state and player activity using Cloud Spanner.
- Create tables and define indexes in Cloud Spanner to support efficient data retrieval.
- Establish relationships and enforce data consistency between entities in Cloud Spanner.
- Integrate Cloud Spanner into the gaming application for real-time updates and retrieval of game state and activity data.

### Prerequisites

- Familiarity with database concepts, such as tables, indexes, and relationships.
- Understanding of relational database management systems (RDBMS) and SQL.
- Basic knowledge of game development and multiplayer game architecture.

### Materials

- [Google Cloud Spanner](https://cloud.google.com/spanner/docs)
- [Spanner Gaming Sample](https://github.com/cloudspannerecosystem/spanner-gaming-sample)
- [Global Multiplayer Sample](https://github.com/googleforgames/global-multiplayer-demo)

### Suggested Steps

1. **Research and Familiarization:** Participants should begin by researching and understanding the key concepts of Cloud Spanner. They should review the documentation, tutorials, and examples provided by Google Cloud to gain a solid understanding of how Cloud Spanner works and its capabilities.

2. **Schema Design:** Participants need to design a schema for storing game state and player activity in Cloud Spanner. They should identify the entities, attributes, and relationships involved in the gaming application and determine the appropriate table structure. Considerations should be given to data consistency, scalability, and performance.

3. **Table Creation and Indexing:** Participants should create tables in Cloud Spanner based on the designed schema. They need to define the appropriate column types, constraints, and indexes to support efficient data retrieval and querying. Participants should consider the types of queries that will be performed on the game state and player activity data and create indexes accordingly.

4. **Relationship Establishment:** Participants should establish relationships between entities in Cloud Spanner to enforce data consistency and integrity. They need to define appropriate foreign key constraints and cascading actions to maintain referential integrity. Participants should consider the impact of updates and deletions on related entities and handle them accordingly.

5. **Integration with Gaming Application:** Participants should integrate Cloud Spanner into their gaming application. They need to modify the game client and server code to communicate with Cloud Spanner for real-time updates and retrieval of game state and player activity data. This may involve using appropriate database drivers or libraries and implementing the necessary API calls.

6. **Testing and Validation:** Participants should thoroughly test and validate the integration of Cloud Spanner into the gaming application. They should verify that game state updates and player activity data are accurately stored and retrieved from Cloud Spanner. They should also test scenarios involving concurrent updates and ensure data consistency is maintained.

7. **Optimization and Performance Tuning:** Participants should optimize the performance of Cloud Spanner in the gaming application. They should consider techniques such as query optimization, index tuning, and appropriate use of transactional boundaries. They can monitor performance metrics and identify areas for improvement to enhance the overall gaming experience.

8. **Documentation and Presentation:** Participants should document their implementation process, challenges faced, and solutions applied. They should prepare a presentation summarizing their approach, results, and any insights gained from using Cloud Spanner as the game state and activity store.

### Tips and Recommendations

- Encourage participants to explore the Cloud Spanner documentation thoroughly and make use of the provided examples and best practices.
- Remind participants to consider the scalability and performance requirements of their gaming application when designing the schema and defining indexes.
- Emphasize the importance of testing concurrent updates and ensuring data consistency when integrating Cloud Spanner into the gaming application.

### Conclusion

Using Cloud Spanner as the game state and activity store provides participants with a highly available and scalable database solution for their gaming application. By successfully completing this challenge, participants have gained hands-on experience with Cloud Spanner and enhanced their skills in designing and integrating databases into multiplayer game environments.

## Challenge 4: Player Churn Prediction with BigQuery ML

### Notes & Guidance

In this challenge, participants will use BigQuery ML to build a churn prediction model for a gaming app. They will utilize Google Analytics 4 data from the app to determine the likelihood of specific users returning to the app after the first 24 hours. Participants will follow a step-by-step process outlined in a blog post to preprocess the data, train a classification model, evaluate its performance, and make predictions using BigQuery ML.

### Objectives

- Preprocess raw event data from Google Analytics 4.
- Identify users and the label feature for churn prediction.
- Process demographic and behavioral features from the data.
- Train a classification model using BigQuery ML.
- Evaluate the model's performance.
- Make predictions using the trained model.
- Discuss practical implementations of model insights.

### Prerequisites

- Familiarity with SQL queries and data preprocessing.
- Basic knowledge of machine learning concepts.
- Understanding of BigQuery and its ML capabilities.

### Materials

- [BigQuery Sample Dataset for Gaming App](https://developers.google.com/analytics/bigquery/app-gaming-demo-dataset)
- [Blog post: Player Churn Prediction with BigQuery ML](https://cloud.google.com/blog/topics/developers-practitioners/churn-prediction-game-developers-using-google-analytics-4-ga4-and-bigquery-ml)
- [BigQuery Documentation](https://cloud.google.com/bigquery/docs)
- [BigQuery ML Documentation](https://cloud.google.com/bigquery/docs/bqml-introduction)

### Suggested Steps

1. **Preprocessing the Raw Event Data:** Participants should preprocess the raw event data from Google Analytics 4 to transform it into an appropriate format for training a machine learning model. They need to follow the step-by-step instructions provided in the blog post or Jupyter Notebook.

2. **Identifying Users and Label Feature:** Participants should identify the users and define the label feature for churn prediction. They need to filter the dataset to remove users who are unlikely to return to the app and label the remaining users as either churned or returned based on their event records.

3. **Processing Demographic Features:** Participants should process the demographic features from the data, such as country, device operating system, and language. They need to extract the values from the first user engagement event and create a view or table containing the demographic data.

4. **Processing Behavioral Features:** Participants should process the behavioral features from the data, including user activities within the first 24 hours of app engagement. They need to count the occurrences of specific events and aggregate the behavioral data for each user.

5. **Training the Classification Model:** Participants should use BigQuery ML to train a classification model for churn prediction. They need to create a model using the appropriate algorithm (e.g., logistic regression) and specify the input features and label. Participants should refer to the blog post or Jupyter Notebook for the query examples.

6. **Evaluating the Model:** Participants should evaluate the performance of the trained model using metrics such as precision, recall, accuracy, and F1-score. They need to run the evaluation query provided in the blog post or Jupyter Notebook to generate the evaluation metrics.

7. **Making Predictions:** Participants should use the trained model to make predictions on the dataset. They need to run the prediction query provided in the blog post or Jupyter Notebook to obtain the probability of users returning to the app after 24 hours.

8. **Implementing Model Insights:** Participants should discuss and explore practical implementations of the model insights. They can consider importing the model predictions back into Google Analytics as user attributes, utilizing the predictions for targeted marketing campaigns, or integrating the predictions with other systems.

9. **Documentation and Presentation:** Participants should document their approach, steps followed, and any challenges faced during the challenge. They should prepare a presentation summarizing their process, key findings, and potential use cases for the churn prediction model.

### Tips and Recommendations

- Emphasize the importance of data preprocessing and feature engineering in building an effective churn prediction model.
- Encourage participants to understand the specific requirements and formats of the input data for BigQuery ML.
- Advise participants to thoroughly analyze and interpret the evaluation metrics to assess the model's performance.
- Suggest participants explore different practical implementations based on the model insights and discuss their potential impact on user retention and engagement.

### Conclusion

Predicting player churn is crucial for game developers to retain and engage their users effectively. By completing this challenge, participants have gained hands-on experience with using BigQuery ML to build a churn prediction model using Google Analytics 4 data. They have learned how to preprocess the data, train a classification model, evaluate its performance, and make predictions. This knowledge will enable them to develop effective strategies for player retention and implement data-driven decision-making processes in the gaming industry.
