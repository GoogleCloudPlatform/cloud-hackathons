import os
import csv
import requests
from flask import Flask, jsonify, request
from google.cloud import pubsub_v1

app = Flask(__name__)

def get_project_id():
    """
    Gets the project ID from the metadata server.
    """
    metadata_server_url = "http://metadata.google.internal/computeMetadata/v1/project/project-id"
    headers = {"Metadata-Flavor": "Google"}

    try:
        response = requests.get(metadata_server_url, headers=headers)
        response.raise_for_status()  # Raise an exception for bad status codes
        return response.text
    except requests.exceptions.RequestException as e:
        print(f"Error getting project ID: {e}")
        return None

@app.route("/team", methods=["GET"])
def get_team_name():
    """
    Pulls a message from a Pub/Sub subscription and returns the team name.
    """
    if not (project_id := get_project_id()):
        return "Error getting project ID", 500

    subscription_name = request.args.get("subscription", "team-name-vendor-sub")
    subscription_path = f"projects/{project_id}/subscriptions/{subscription_name}"

    with pubsub_v1.SubscriberClient() as subscriber:
        try:
            response = subscriber.pull(subscription=subscription_path, max_messages=1)
            if not response.received_messages:
                return jsonify({"name": "No messages available"}), 200

            received_message = response.received_messages[0] # type: ignore
            team_name = received_message.message.data.decode("utf-8")

            subscriber.acknowledge(subscription=subscription_path, ack_ids=[received_message.ack_id])

            return jsonify({"name": team_name}), 200

        except Exception as e:
            print(f"An error occurred: {e}")
            return jsonify({"error": "An error occurred"}), 500

@app.route("/seed", methods=["POST"])
def seed_team_names():
    """
    Reads team names from a CSV file and publishes them to a Pub/Sub topic.
    """
    csv_filename = "./unique-team-names.csv"
    if not (project_id := get_project_id()):
        return "Error getting project ID", 500

    topic_name = request.args.get("topic", "team-name-vendor")
    topic_path = f"projects/{project_id}/topics/{topic_name}"
    publisher = pubsub_v1.PublisherClient()

    try:
        with open(csv_filename, 'r') as file:
            reader = csv.DictReader(file)
            for row in reader:
                team_name = row['team_name']
                if team_name:
                    message = team_name.encode("utf-8")
                    future = publisher.publish(topic_path, message)
                    print(f"Published message ID: {future.result()}")
        return "Messages published successfully.", 200
    except FileNotFoundError:
        return f"Error: CSV file not found at {csv_filename}", 500
    except Exception as e:
        print(f"An error occurred: {e}")
        return "An error occurred.", 500

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))