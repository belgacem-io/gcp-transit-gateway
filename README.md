<!-- BEGIN_TF_DOCS -->
### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/belgacem-io/gcp-transit-gateway.git
   ```
2. In your GCP project, create service account and a service account key then download the credentials file as JSON
3. Create an '.auth/env' file and add required variables
   ```sh
   ##################################### GCP Credentials ###################
   export GOOGLE_APPLICATION_CREDENTIALS=/wks/.auth/application_default_credentials.json
   export PROJECT_ID=poc-tgw-375008
   export PROJECT_NAME=poc-tgw

   ```
4. Setup your local environment
   ```sh
    make up
    ./terraformd --insall
   ```

5. Init terraform modules
   ```sh
    terraformd init
   ```
6. Apply terraform resources
   ```sh
    terraformd apply
   ```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_hub_data_subnets"></a> [hub\_data\_subnets](#input\_hub\_data\_subnets) | The list of data subnets being created for HUB | <pre>list(object({<br>    project_name = string<br>    subnet_name  = string<br>    subnet_ip    = string<br>  }))</pre> | `[]` | no |
| <a name="input_hub_private_subnets"></a> [hub\_private\_subnets](#input\_hub\_private\_subnets) | The list of private subnets being created for HUB | <pre>list(object({<br>    project_name = string<br>    subnet_name  = string<br>    subnet_ip    = string<br>  }))</pre> | `[]` | no |
| <a name="input_hub_private_svc_connect_subnets"></a> [hub\_private\_svc\_connect\_subnets](#input\_hub\_private\_svc\_connect\_subnets) | The list of subnets to publish a managed service by using Private Service Connect. | <pre>list(object({<br>    project_name = string<br>    subnet_name  = string<br>    subnet_ip    = string<br>  }))</pre> | `[]` | no |
| <a name="input_hub_public_subnets"></a> [hub\_public\_subnets](#input\_hub\_public\_subnets) | The list of public subnets being created for HUB | <pre>list(object({<br>    project_name = string<br>    subnet_name  = string<br>    subnet_ip    = string<br>  }))</pre> | `[]` | no |
| <a name="input_spoke1_data_subnets"></a> [spoke1\_data\_subnets](#input\_spoke1\_data\_subnets) | The list of data subnets being created for spoke 1 | <pre>list(object({<br>    project_name = string<br>    subnet_name  = string<br>    subnet_ip    = string<br>  }))</pre> | `[]` | no |
| <a name="input_spoke1_private_subnets"></a> [spoke1\_private\_subnets](#input\_spoke1\_private\_subnets) | The list of private subnets being created for spoke 1 | <pre>list(object({<br>    project_name = string<br>    subnet_name  = string<br>    subnet_ip    = string<br>  }))</pre> | `[]` | no |
| <a name="input_spoke2_data_subnets"></a> [spoke2\_data\_subnets](#input\_spoke2\_data\_subnets) | The list of data subnets being created for spoke 2 | <pre>list(object({<br>    project_name = string<br>    subnet_name  = string<br>    subnet_ip    = string<br>  }))</pre> | `[]` | no |
| <a name="input_spoke2_private_subnets"></a> [spoke2\_private\_subnets](#input\_spoke2\_private\_subnets) | The list of private subnets being created for spoke 2 | <pre>list(object({<br>    project_name = string<br>    subnet_name  = string<br>    subnet_ip    = string<br>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->