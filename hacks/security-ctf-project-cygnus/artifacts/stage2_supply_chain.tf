# stage2_supply_chain.tf
#
# Sets up the intentionally vulnerable resources for Stage 2.
# v2.0: Removed the pre-creation of the Artifact Registry repository,
#       as this is a task for the CTF participant.

# --- VULNERABILITY 3: Source repo with an insecure Dockerfile ---
resource "google_sourcerepo_repository" "app_source_code" {
  name = "cygnus-processor-app"
  depends_on = [google_project_service.cygnus_apis]
}

# Use local-exec to clone the new repo, add a vulnerable file, and push it.
resource "null_resource" "setup_vulnerable_source_repo" {
  provisioner "local-exec" {
    command = <<-EOT
      gcloud source repos clone cygnus-processor-app && \
      cd cygnus-processor-app && \
      echo 'FROM python:3.9-slim\n\nWORKDIR /app\n\nCOPY . /app\n\nCMD ["python", "main.py"]' > Dockerfile && \
      echo 'print("Vulnerable application running")' > main.py && \
      git config --global user.email "ctf-setup@example.com" && \
      git config --global user.name "CTF Setup" && \
      git add . && \
      git commit -m "Initial insecure commit" && \
      git push origin master
    EOT
  }
  depends_on = [google_sourcerepo_repository.app_source_code]
}
