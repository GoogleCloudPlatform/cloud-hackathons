import os
import requests
from flask import Flask, jsonify, request
from google.cloud import dns
from google.api_core import exceptions

app = Flask(__name__)

# --- Configuration ---
ZONE_NAME = "media-ghacks-dev"
ZONE_DOMAIN = "media.ghacks.dev"
DEFAULT_TTL = 3000
NAMESERVERS = [
    "ns-cloud-b1.googledomains.com.",
    "ns-cloud-b2.googledomains.com.",
    "ns-cloud-b3.googledomains.com.",
    "ns-cloud-b4.googledomains.com.",
]

def get_project_id():
    """Gets the project ID from the metadata server or environment."""
    metadata_server_url = "http://metadata.google.internal/computeMetadata/v1/project/project-id"
    headers = {"Metadata-Flavor": "Google"}
    try:
        response = requests.get(metadata_server_url, headers=headers, timeout=5)
        response.raise_for_status()
        return response.text
    except requests.exceptions.RequestException:
        print("Could not connect to metadata server. Falling back to environment variable.")
        return os.environ.get("GOOGLE_CLOUD_PROJECT")

PROJECT_ID = get_project_id()
if not PROJECT_ID:
    raise EnvironmentError("GCP Project ID not found. Please set GOOGLE_CLOUD_PROJECT for local dev.")

dns_client = dns.Client(project=PROJECT_ID)
zone = dns_client.zone(ZONE_NAME, f"{ZONE_DOMAIN}.")

@app.route("/subdomain", methods=["POST"])
def add_subdomain():
    """
    Adds a new NS record for a subdomain.
    Expects JSON payload: {"subdomain": "your-subdomain"}
    """
    data = request.get_json()
    if not data or "subdomain" not in data:
        return jsonify({"error": "Missing 'subdomain' in request body"}), 400

    subdomain = data["subdomain"]
    fqdn = f"{subdomain}.{ZONE_DOMAIN}."

    try:
        # Check if record already exists
        for record in zone.list_resource_record_sets():
            if record.name == fqdn and record.record_type == 'NS':
                return jsonify({"error": f"Record {fqdn} already exists."}), 409

        record_set = zone.resource_record_set(fqdn, "NS", DEFAULT_TTL, NAMESERVERS)
        changes = zone.changes()
        changes.add_record_set(record_set)
        changes.create()

        # Wait for the change to complete
        while changes.status != "done":
            changes.reload()

        return jsonify({"message": f"Successfully created NS record for {fqdn}"}), 201

    except exceptions.GoogleAPICallError as e:
        print(f"API Error creating record: {e}")
        return jsonify({"error": "An API error occurred.", "details": str(e)}), 500
    except Exception as e:
        error_details = f"{type(e).__name__}: {e}"
        print(f"An unexpected error occurred: {error_details}")
        return jsonify({
            "error": "An unexpected error occurred. Check logs for details.",
            "details": error_details
        }), 500

@app.route("/subdomain", methods=["DELETE"])
def remove_subdomain():
    """
    Removes an NS record for a subdomain.
    Expects JSON payload: {"subdomain": "your-subdomain"}
    """
    data = request.get_json()
    if not data or "subdomain" not in data:
        return jsonify({"error": "Missing 'subdomain' in request body"}), 400

    subdomain = data["subdomain"]
    fqdn = f"{subdomain}.{ZONE_DOMAIN}."

    try:
        record_to_delete = None
        # Find the exact record to delete
        for record in zone.list_resource_record_sets():
            if record.name == fqdn and record.record_type == "NS":
                record_to_delete = record
                break

        if not record_to_delete:
            return jsonify({"error": f"Record {fqdn} not found."}), 404

        changes = zone.changes()
        changes.delete_record_set(record_to_delete)
        changes.create()

        # Wait for the change to complete
        while changes.status != "done":
            changes.reload()

        return jsonify({"message": f"Successfully deleted NS record for {fqdn}"}), 200

    except exceptions.GoogleAPICallError as e:
        print(f"API Error deleting record: {e}")
        return jsonify({"error": "An API error occurred.", "details": str(e)}), 500
    except Exception as e:
        error_details = f"{type(e).__name__}: {e}"
        print(f"An unexpected error occurred: {error_details}")
        return jsonify({
            "error": "An unexpected error occurred. Check logs for details.",
            "details": error_details
        }), 500


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))