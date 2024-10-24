# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

output "locust_address" {
  value = "http://${data.kubernetes_service.locust.status.0.load_balancer.0.ingress.0.ip}:8089"
}

output "backend_address" {
  value = "http://${google_compute_address.server-address.address}"
}

output "frontend_address" {
  value = "http://${google_compute_address.frontend-address.address}"
}