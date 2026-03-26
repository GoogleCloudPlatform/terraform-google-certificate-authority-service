# terraform-google-cas

## Description
### Tagline
This is an auto-generated module.

### Detailed
This module was generated from [terraform-google-module-template](https://github.com/terraform-google-modules/terraform-google-module-template/), which by default generates a module that simply creates a GCS bucket. As the module develops, this README should be updated.

The resources/services/activations/deletions that this module will create/trigger are:

- Create a GCS bucket with the provided name

### PreDeploy
To deploy this blueprint you must have an active billing account and billing permissions.

## Architecture
![alt text for diagram](https://www.link-to-architecture-diagram.com)
1. Architecture description step no. 1
2. Architecture description step no. 2
3. Architecture description step no. N

## Documentation
- [Hosting a Static Website](https://cloud.google.com/storage/docs/hosting-static-website)

## Deployment Duration
Configuration: X mins
Deployment: Y mins

## Cost
[Blueprint cost details](https://cloud.google.com/products/calculator?id=02fb0c45-cc29-4567-8cc6-f72ac9024add)

## Usage

Basic usage of this module is as follows:

```hcl
module "cas" {
  source  = "terraform-google-modules/cas/google"
  version = "~> 0.2"

  project_id  = "<PROJECT ID>"
  bucket_name = "gcs-test-bucket"
}
```

Functional examples are included in the
[examples](./examples/) directory.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ca\_configs | List of configurations for the Certificate Authorities to create. | <pre>map(object({<br>    is_ca                                  = optional(bool, true)<br>    deletion_protection                    = optional(bool, false)<br>    skip_grace_period                      = optional(bool, true)<br>    ignore_active_certificates_on_deletion = optional(bool, false)<br>    gcs_bucket                             = optional(string)<br>    labels                                 = optional(map(string), {})<br>    subject = object({<br>      common_name         = string<br>      organization        = string<br>      country_code        = optional(string)<br>      locality            = optional(string)<br>      postal_code         = optional(string)<br>      province            = optional(string)<br>      street_address      = optional(string)<br>      organizational_unit = optional(string)<br>    })<br>    subject_alt_name = optional(object({<br>      dns_names       = optional(list(string))<br>      email_addresses = optional(list(string))<br>      ip_addresses    = optional(list(string))<br>      uris            = optional(list(string))<br>    }))<br>    key_usage = object({<br>      cert_sign          = optional(bool, true)<br>      crl_sign           = optional(bool, true)<br>      server_auth        = optional(bool, true)<br>      client_auth        = optional(bool, false)<br>      code_signing       = optional(bool, false)<br>      content_commitment = optional(bool, false)<br>      data_encipherment  = optional(bool, false)<br>      decipher_only      = optional(bool, false)<br>      digital_signature  = optional(bool, false)<br>      email_protection   = optional(bool, false)<br>      encipher_only      = optional(bool, false)<br>      key_agreement      = optional(bool, false)<br>      key_encipherment   = optional(bool, true)<br>      ocsp_signing       = optional(bool, false)<br>      time_stamping      = optional(bool, false)<br>    })<br>    key_spec = object({<br>      algorithm  = optional(string, "RSA_PKCS1_2048_SHA256")<br>      kms_key_id = optional(string)<br>    })<br>    subordinate_config = optional(object({<br>      root_ca_id              = string<br>      pem_issuer_certificates = optional(list(string))<br>    }))<br>  }))</pre> | `{}` | no |
| ca\_pool\_config | Configuration for the Certificate Authority pool. Exactly one of 'create\_pool' (to create a new pool) or 'use\_pool' (to use an existing one) must be provided. | <pre>object({<br>    create_pool = optional(object({<br>      name            = string<br>      enterprise_tier = optional(bool, false)<br>    }))<br>    use_pool = optional(object({<br>      id = string<br>    }))<br>  })</pre> | n/a | yes |
| iam | IAM bindings to apply to the CA pool. | <pre>map(object({<br>    role   = string<br>    member = string<br>  }))</pre> | `{}` | no |
| location | The location for the CA pool and certificate authority. | `string` | n/a | yes |
| project\_id | The ID of the project in which the resources will be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| ca\_chains | The CA chains in PEM format. |
| ca\_ids | The CA ids. |
| ca\_pool | The CA pool resource. |
| ca\_pool\_id | The full resource ID of the CA Pool (e.g., 'projects/my-project/locations/us-central1/caPools/my-subordinate-pool-v1'). |
| ca\_pool\_name | The short, user-defined name of the CA Pool (e.g., 'my-subordinate-pool-v1'). |
| ca\_roots | The root CA certificates in PEM format, concatenated with newlines. |
| cas | The Certificate Authority resources. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform][terraform] v0.13
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v3.0

### Service Account

A service account with the following roles must be used to provision
the resources of this module:

- Storage Admin: `roles/storage.admin`

The [Project Factory module][project-factory-module] and the
[IAM module][iam-module] may be used in combination to provision a
service account with the necessary roles applied.

### APIs

A project with the following APIs enabled must be used to host the
resources of this module:

- Google Cloud Storage JSON API: `storage-api.googleapis.com`

The [Project Factory module][project-factory-module] can be used to
provision a project with the necessary APIs enabled.

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.

[iam-module]: https://registry.terraform.io/modules/terraform-google-modules/iam/google
[project-factory-module]: https://registry.terraform.io/modules/terraform-google-modules/project-factory/google
[terraform-provider-gcp]: https://www.terraform.io/docs/providers/google/index.html
[terraform]: https://www.terraform.io/downloads.html

## Security Disclosures

Please see our [security disclosure process](./SECURITY.md).
