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