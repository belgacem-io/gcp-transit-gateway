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
4. Create your terraform.tfvars
   ```hcl
   project_id         = "poc-tgw"
   default_region     = "europe-west9"
   hub_public_subnets = [
     {
       subnet_name = "public"
       subnet_ip   = "192.168.0.0/24"
     }
   ]
   
   hub_private_subnets = [
     {
       subnet_name = "private"
       subnet_ip   = "192.168.1.0/24"
     }
   ]
   
   hub_private_svc_connect_subnets = [
     {
       subnet_name = "svcc"
       subnet_ip   = "192.168.2.0/24"
     }
   ]
   spoke1_private_subnets     = [
     {
       subnet_name = "private"
       subnet_ip   = "10.0.1.0/24"
     }
   ]
   ```

5. Init terraform modules
   ```sh
    terraform init
   ```
6. Apply terraform resources
   ```sh
    terraform apply
   ```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_default_region"></a> [default\_region](#input\_default\_region) | Default region 1 for subnets and Cloud Routers | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID for Private Shared VPC. | `string` | n/a | yes |
| <a name="input_hub_private_subnets"></a> [hub\_private\_subnets](#input\_hub\_private\_subnets) | The list of private subnets being created for HUB | <pre>list(object({<br>    subnet_name  = string<br>    subnet_ip    = string<br>  }))</pre> | `[]` | no |
| <a name="input_hub_private_svc_connect_subnets"></a> [hub\_private\_svc\_connect\_subnets](#input\_hub\_private\_svc\_connect\_subnets) | The list of subnets to publish a managed service by using Private Service Connect. | <pre>list(object({<br>    subnet_name  = string<br>    subnet_ip    = string<br>  }))</pre> | `[]` | no |
| <a name="input_hub_public_subnets"></a> [hub\_public\_subnets](#input\_hub\_public\_subnets) | The list of public subnets being created for HUB | <pre>list(object({<br>    subnet_name  = string<br>    subnet_ip    = string<br>  }))</pre> | `[]` | no |
| <a name="input_spoke1_private_subnets"></a> [spoke1\_private\_subnets](#input\_spoke1\_private\_subnets) | The list of private subnets being created for spoke 1 | <pre>list(object({<br>    subnet_name  = string<br>    subnet_ip    = string<br>  }))</pre> | `[]` | no |
| <a name="input_spoke2_private_subnets"></a> [spoke2\_private\_subnets](#input\_spoke2\_private\_subnets) | The list of private subnets being created for spoke 2 | <pre>list(object({<br>    subnet_name  = string<br>    subnet_ip    = string<br>  }))</pre> | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->