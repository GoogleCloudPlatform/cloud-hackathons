/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# [START compute_instances_quickstart]
resource "google_compute_instance" "default" {
  name         = "ateme-nl"
  machine_type = "c4d-standard-8"
  zone         = "europe-west2-b"

  boot_disk {
    initialize_params {
      image = "projects/media-on-gcp-storage/global/images/ateme-nl-250625"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
}
# [END compute_instances_quickstart]
