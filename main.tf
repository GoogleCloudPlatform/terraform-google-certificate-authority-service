/**
 * Copyright 2026 Google LLC
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

locals {
  # 1. Short, user-defined name of the CA Pool (e.g., "my-subordinate-pool-v1").
  # This is used for arguments like 'pool' in google_privateca_certificate_authority
  # and 'ca_pool' in google_privateca_ca_pool_iam_member, and for the 'ca_pool_name' output.
  ca_pool_short_name = (
    var.ca_pool_config.create_pool != null
    ? google_privateca_ca_pool.default[0].name
    : reverse(split("/", var.ca_pool_config.use_pool.id))[0]
  )

  # 2. Full resource ID of the CA Pool (e.g., "projects/.../caPools/...").
  # This is used for the 'ca_pool_id' output.
  ca_pool_full_id = (
    var.ca_pool_config.create_pool != null
    ? (length(google_privateca_ca_pool.default) > 0 ? google_privateca_ca_pool.default[0].id : null)
    : var.ca_pool_config.use_pool.id
  )
}

# --- Step 1: Enable the Private CA API ---
resource "google_project_service" "privateca_api" {
  project            = var.project_id
  service            = "privateca.googleapis.com"
  disable_on_destroy = false
}

# --- Step 2: Handle API Propagation Delay ---
resource "time_sleep" "wait_for_privateca_api" {
  depends_on      = [google_project_service.privateca_api]
  create_duration = "45s"
}

# --- Step 3: Create the CA Pool ---
resource "google_privateca_ca_pool" "default" {
  count    = var.ca_pool_config.create_pool != null ? 1 : 0
  name     = var.ca_pool_config.create_pool.name
  location = var.location
  project  = var.project_id
  tier     = var.ca_pool_config.create_pool.enterprise_tier ? "ENTERPRISE" : "DEVOPS"

  depends_on = [time_sleep.wait_for_privateca_api]
}

# --- Step 4: Create Certificate Authorities ---
resource "google_privateca_certificate_authority" "default" {
  for_each = var.ca_configs

  # Use the short name of the CA Pool
  pool                     = local.ca_pool_short_name
  certificate_authority_id = each.key
  location                 = var.location
  project                  = var.project_id

  # Deduce type from the presence of subordinate_config (fixes the type conflict)
  type = each.value.subordinate_config != null ? "SUBORDINATE" : "SELF_SIGNED"

  deletion_protection                    = each.value.deletion_protection
  skip_grace_period                      = each.value.skip_grace_period
  ignore_active_certificates_on_deletion = each.value.ignore_active_certificates_on_deletion
  gcs_bucket                             = each.value.gcs_bucket
  labels                                 = each.value.labels

  config {
    subject_config {
      subject {
        common_name         = each.value.subject.common_name
        organization        = each.value.subject.organization
        country_code        = each.value.subject.country_code
        locality            = each.value.subject.locality
        organizational_unit = each.value.subject.organizational_unit
        postal_code         = each.value.subject.postal_code
        province            = each.value.subject.province
        street_address      = each.value.subject.street_address
      }
      dynamic "subject_alt_name" {
        for_each = each.value.subject_alt_name != null ? [1] : []
        content {
          dns_names       = each.value.subject_alt_name.dns_names
          email_addresses = each.value.subject_alt_name.email_addresses
          ip_addresses    = each.value.subject_alt_name.ip_addresses
          uris            = each.value.subject_alt_name.uris
        }
      }
    }
    x509_config {
      ca_options {
        is_ca = each.value.is_ca
      }
      key_usage {
        base_key_usage {
          cert_sign          = each.value.key_usage.cert_sign
          content_commitment = each.value.key_usage.content_commitment
          crl_sign           = each.value.key_usage.crl_sign
          data_encipherment  = each.value.key_usage.data_encipherment
          decipher_only      = each.value.key_usage.decipher_only
          digital_signature  = each.value.key_usage.digital_signature
          encipher_only      = each.value.key_usage.encipher_only
          key_agreement      = each.value.key_usage.key_agreement
          key_encipherment   = each.value.key_usage.key_encipherment
        }
        extended_key_usage {
          client_auth      = each.value.key_usage.client_auth
          code_signing     = each.value.key_usage.code_signing
          email_protection = each.value.key_usage.email_protection
          ocsp_signing     = each.value.key_usage.ocsp_signing
          server_auth      = each.value.key_usage.server_auth
          time_stamping    = each.value.key_usage.time_stamping
        }
      }
    }
  }

  key_spec {
    algorithm             = each.value.key_spec.algorithm
    cloud_kms_key_version = each.value.key_spec.kms_key_id
  }

  # Subordinate Configuration Mapping (triggers when non-self-signed)
  dynamic "subordinate_config" {
    for_each = each.value.subordinate_config != null ? [1] : []
    content {
      certificate_authority = each.value.subordinate_config.root_ca_id
      dynamic "pem_issuer_chain" {
        for_each = each.value.subordinate_config.pem_issuer_certificates != null ? [1] : []
        content {
          pem_certificates = each.value.subordinate_config.pem_issuer_certificates
        }
      }
    }
  }

  depends_on = [google_privateca_ca_pool.default]
}

# --- Step 5: IAM Manager (CA Pool Access) ---
resource "google_privateca_ca_pool_iam_member" "default" {
  for_each = var.iam

  # Use the short name of the CA Pool
  ca_pool  = local.ca_pool_short_name
  project  = var.project_id
  location = var.location

  role   = each.value.role
  member = each.value.member

  depends_on = [google_privateca_ca_pool.default]
}
