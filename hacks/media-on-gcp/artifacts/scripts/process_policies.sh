#!/bin/bash

# --- Google Cloud Policy Processor ---
# This script automates the replacement of environment variables and
# the splitting of a multi-document YAML policy file into individual files.

# --- 1. Prompt for Environment Variable Values ---
echo "Please provide the values for your Google Cloud environment variables."
read -p "Enter GCP_PROJECT_ID (e.g., 'my-project-123'): " GCP_PROJECT_ID
read -p "Enter GCP_PROJECT_ID_SOURCE (e.g., 'my-source-project-456'): " GCP_PROJECT_ID_SOURCE
read -p "Enter TARGET_ORGANIZATION_ID (e.g., '123456789012'): " TARGET_ORGANIZATION_ID

# --- 2. Define Input File ---
# This is the name of the file that will contain your policies.
INPUT_FILE="input_policies.yaml"

# --- 3. Create Input Policy File ---
# The script will create this file with your provided content.
# Using 'EOF' (single quotes) prevents shell expansion of variables *within* the heredoc,
# ensuring that '$GCP_PROJECT_ID' is written literally to the file.
cat <<'EOF' > "$INPUT_FILE"
name: projects/$GCP_PROJECT_ID/policies/compute.trustedImageProjects
spec:
  inheritFromParent: true
  rules:
  - values:
      allowedValues:
      - projects/id3as-public # public image for Norks
      - projects/media-on-gcp-storage # created custom image for Techex
---
name: projects/$GCP_PROJECT_ID/policies/compute.storageResourceUseRestrictions
spec:
  inheritFromParent: true
  rules:
  - values:
      allowedValues:
      - under:projects/media-on-gcp-storage
---
name: projects/$GCP_PROJECT_ID/policies/compute.vmExternalIpAccess
spec:
  rules:
  - enforce: true
---
name: projects/$GCP_PROJECT_ID_SOURCE/policies/iam.allowedPolicyMemberDomains
spec:
  inheritFromParent: true
  rules:
  - values:
      allowedValues:
      - is:principalSet://iam.googleapis.com/organizations/$TARGET_ORGANIZATION_ID
EOF

echo "Input policies saved to '$INPUT_FILE'."

# --- 4. Define AWK Processing Logic ---
# This AWK script handles the core logic:
# - Splits the input file by '---' (YAML document separator).
# - Performs variable substitution using the values provided by the user.
# - Extracts the policy name from the 'name:' field to use as the output filename.
# - Creates a 'processed_policies' directory if it doesn't exist.
# - Writes each processed policy block to a new .yaml file.
AWK_SCRIPT=$(cat <<'AWK'
# BEGIN block: Executed once before processing any input lines.
BEGIN {
    # Default prefix for filenames if a policy name cannot be extracted.
    file_prefix = "policy_"
    # Counter for sequential policy files.
    file_num = 0
    # Variable to hold the current output filename.
    output_filename = ""
    # Create the directory to store processed policies.
    system("mkdir -p processed_policies")
}

# This block is executed when the line matches '---'.
/^---$/ {
    # If a file was open, close it before starting a new one.
    if (output_filename != "") {
        close(output_filename)
    }
    # Increment file number for generic naming if needed.
    file_num++
    # Reset output_filename to indicate a new block has started and its name is yet to be determined.
    output_filename = ""
    # Skip the '---' line itself from being processed further.
    next
}

# This block is executed for every line that is NOT '---'.
{
    line = $0 # Current line content.
    # Perform variable substitutions.
    # IMPORTANT: Replace longer variable names first to avoid partial matches.
    gsub(/\$GCP_PROJECT_ID_SOURCE/, GCP_PROJECT_ID_SOURCE, line) # Replace this first
    gsub(/\$GCP_PROJECT_ID/, GCP_PROJECT_ID, line)             # Then this
    gsub(/\$TARGET_ORGANIZATION_ID/, TARGET_ORGANIZATION_ID, line)

    # If the output filename for the current block has not yet been determined.
    if (output_filename == "") {
        # Check if the line contains "name: projects/" and "/policies/"
        if (line ~ /^name: projects\/.*\/policies\//) {
            # Find the starting position of the policy name after "/policies/"
            policy_start_index = index(line, "/policies/")
            if (policy_start_index > 0) {
                # Extract the part of the string that contains the policy name
                # This grabs everything after "/policies/"
                policy_name_raw = substr(line, policy_start_index + length("/policies/"))

                # Remove any comments (e.g., " # public image") and leading/trailing whitespace
                gsub(/ #.*$/, "", policy_name_raw)
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", policy_name_raw)

                # Split by '/' to handle constraints like 'constraints/compute.vmExternalIpAccess'
                split(policy_name_raw, path_parts, "/")
                # The actual policy name is the last part
                extracted_name = path_parts[length(path_parts)]

                # Sanitize the extracted name to ensure it's a valid filename.
                gsub(/[^a-zA-Z0-9._-]/, "_", extracted_name)
                # Construct the full path for the output file.
                output_filename = "processed_policies/" extracted_name ".yaml"
            } else {
                # Fallback if "policies/" substring is not found, though unlikely given the regex
                output_filename = "processed_policies/" file_prefix file_num ".yaml"
            }
        } else {
            # Fallback if 'name:' line is not found or not in the expected format.
            output_filename = "processed_policies/" file_prefix file_num ".yaml"
        }
    }
    # Print the processed line to the determined output file.
    print line > output_filename
}

# END block: Executed once after all input lines have been processed.
END {
    # Ensure the last opened file is closed.
    if (output_filename != "") {
        close(output_filename)
    }
}
AWK
)

# --- 5. Execute the AWK Script ---
# Run AWK, passing the user-provided variables to the AWK script.
awk -v GCP_PROJECT_ID="$GCP_PROJECT_ID" \
    -v GCP_PROJECT_ID_SOURCE="$GCP_PROJECT_ID_SOURCE" \
    -v TARGET_ORGANIZATION_ID="$TARGET_ORGANIZATION_ID" \
    "$AWK_SCRIPT" "$INPUT_FILE"

# --- 6. Completion Message ---
echo "Processing complete. Check the 'processed_policies' directory for the generated files."
echo "You can list the generated files by running: ls processed_policies"
echo "Or view the content of a file, for example: cat processed_policies/compute.trustedImageProjects.yaml"
echo "Remember to delete the input_policies.yaml file and the processed_policies directory if you no longer need them."
