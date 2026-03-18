/**
 * Copyright 2021 Google LLC
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

module "cas" {
  source = "../.."

  project_id = var.project_id
  location   = "us-central1"

  ca_pool_config = {
    create_pool = {
      name            = "simple-pool-2"
      enterprise_tier = false # Creates a DEVOPS tier pool
    }
  }

  ca_configs = {
    "simple-ca" = {
      is_ca = true
      subject = {
        common_name  = "simple-ca"
        organization = "Example Org"
      }
      key_usage = {
        cert_sign = true
        crl_sign  = true
      }
      key_spec = {
        algorithm = "RSA_PKCS1_2048_SHA256"
      }
    }
  }
}
