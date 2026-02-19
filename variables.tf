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

variable "project_id" { type = string }
variable "location"   { type = string }

variable "ca_pool_config" {
  type = object({
    create_pool = optional(object({
      name            = string
      enterprise_tier = optional(bool, false)
    }))
    use_pool = optional(object({
      id = string
    }))
  })
}

variable "ca_configs" {
  type = map(object({
    is_ca                                  = optional(bool, true)
    deletion_protection                    = optional(bool, false)
    skip_grace_period                      = optional(bool, true)
    ignore_active_certificates_on_deletion = optional(bool, false)
    gcs_bucket                             = optional(string)
    labels                                 = optional(map(string), {})
    subject = object({
      common_name  = string
      organization = string
      country_code = optional(string)
      locality     = optional(string)
      postal_code  = optional(string)
      province     = optional(string)
      street_address = optional(string)
      organizational_unit = optional(string)
    })
    subject_alt_name = optional(object({
      dns_names       = optional(list(string))
      email_addresses = optional(list(string))
      ip_addresses    = optional(list(string))
      uris            = optional(list(string))
    }))
    key_usage = object({
      cert_sign          = optional(bool, true)
      crl_sign           = optional(bool, true)
      server_auth        = optional(bool, true)
      client_auth        = optional(bool, false)
      code_signing       = optional(bool, false)
      content_commitment = optional(bool, false)
      data_encipherment  = optional(bool, false)
      decipher_only      = optional(bool, false)
      digital_signature  = optional(bool, false)
      email_protection   = optional(bool, false)
      encipher_only      = optional(bool, false)
      key_agreement      = optional(bool, false)
      key_encipherment   = optional(bool, true)
      ocsp_signing       = optional(bool, false)
      time_stamping      = optional(bool, false)
    })
    key_spec = object({
      algorithm  = optional(string, "RSA_PKCS1_2048_SHA256")
      kms_key_id = optional(string)
    })
    subordinate_config = optional(object({
      root_ca_id               = string
      pem_issuer_certificates = optional(list(string))
    }))
  }))
  default = {}
}

variable "iam" {
  type = map(object({
    role   = string
    member = string
  }))
  default = {}
}