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