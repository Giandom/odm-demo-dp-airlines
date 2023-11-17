# README #

In this demo, we are showcasing a Data Product consisting of two interfaces with their respective data contracts:

* SQL Interface: A JDBC connection is exposed to a MySQL database.
* API REST Interface: An REST API is exposed for querying the data.

## Demo Requirements ##
 
 * Azure Subscription
 * Access to Azure DevOps
   * [Azure DevOps Terraform extension](https://marketplace.visualstudio.com/items?itemName=JasonBJohnson.azure-pipelines-tasks-terraform) installed
 * Terraform installed
 * Azure CLI installed
 * cURL or Postman installed

## How do I get set up? ##

### Summary of set up ###

The demo involves running the OpenDataMesh (aka ODM) Platform in the Azure environment, registering the Data Product contained in this demo repository, and finally, deploying it.


#### Prerequisites ####

To release the ODM Platform, you can follow this step-by-step procedure:

1. Access Azure DevOps.
2. If not already present, create a new project.
3. Go to the Repository section (found in the left menu) and click on "Import repository". Select the Git protocol and enter the following link: 
    * https://github.com/opendatamesh-initiative/odm-platform.git
4. Repeat step 3 for the following repositories:
    * https://github.com/opendatamesh-initiative/odm-platform-up-services-executor-azuredevops.git
    * https://github.com/Giandom/odm-demo-dp-airlines.git
5. In the Pipelines section (still in the left menu), click on **Create Pipeline**.
    * The first pipeline to create is for releasing the infrastructure on which the ODM Platform will rely. This pipeline will provision a VM (Standard_A1_v2, 1CPU / 2GB RAM).
        * In the repository connection section, choose Azure Repo and select the **odm-demo-dp-airlines** repository.
        * In the Configure section, select the Existing Azure Pipelines YAML file option. Then choose $master as the branch and **odm-platform-infra/azure-pipelines.yml** as the YAML file.
        * Save the pipeline by selecting Save from the menu near the "Run" button (the pipeline will be saved but not executed).
        * Change the name of the pipeline to **odm-platform-infrastructure**.
    * The second pipeline is for deploying ODM within the infrastructure created by the first pipeline.
        * In the repository connection section, choose Azure Repo and select the imported odm-platform repository.
        * In the Configure section, select the Existing Azure Pipelines YAML file option. Then choose **$main** as the branch and pass the following path: **/azure-pipelines.yml**.
        * Save the pipeline without executing it.
        * Change the name of the pipeline to **odm-platform-application**.
    * The third pipeline is for deploying the ODM Azure DevOps executor, a component that will interface with your Azure DevOps.
        * In the repository connection section, choose Azure Repo and select the imported **odm-platform-up-services-executor-azuredevops** repository.
        * In the Configure section, select the Existing Azure Pipelines YAML file option. Then choose **$main** as the branch and pass the following path: **/azure-pipelines.yml**.
        * Save the pipeline without executing it.
        * Change the name of the pipeline to **odm-platform-executor-azdevops**.
    * The fourth pipeline will provision the infrastructure for the demo (provisioning a VM and a MySQL DB).
        * In the repository connection section, choose Azure Repo and select the **odm-demo-dp-airlines** repository.
        * In the Configure section, select the Existing Azure Pipelines YAML file option. Then choose **$master** as the branch and pass the following path: **infrastructure/azure-pipelines-infra.yml**.
        * Save the pipeline without executing it.
        * Change the name of the pipeline to odm-demo-infrastructure.
    * The fifth and final pipeline is for deploying the application that will expose the REST API.
        * In the repository connection section, choose Azure Repo and select the **odm-demo-dp-airlines** repository.
        * In the Configure section, select the Existing Azure Pipelines YAML file option. Then choose **$master** as the branch and pass the following path: **application/airlinedemo/azure-pipelines-app.yml**.
        * Save the pipeline without executing it.
        * Change the name of the pipeline to **odm-demo-application**.
6. Create an application in your Azure AD to manage the pipelines programmatically:
    * Follow the instructions in [thos document](https://github.com/opendatamesh-initiative/odm-platform-up-services-executor-azuredevops), in the section: **Azure Environment**.
7. Return to Azure DevOps and create an Azure Resource Manager service connection.
    * Go to **Project Settings** (found at the bottom left of Azure DevOps).
    * In the left menu, click on **Service connections** under the Pipelines section.
    * Click on **New service connection**, in the top right, and select **Azure Resource Manager** as the type and **Workload Identity Federation** as the authentication method. Enter the following configurations:
        * Scope level: Choose **Subscription**
        * Subscription: Select the name of your Azure subscription.
        * Resource Group: Select an existing resource group in Azure where resources will be provisioned.
        * Service connection name: Enter  **ODMServiceConnection**
        * Check the option: Grant access permission to all pipelines.
8. Create the following variable groups in the Library section of Azure DevOps:
   * Create a variable group and name it: **ODM-Platform**
      * Add the following variables: 
        * GITHUB_USERNAME: Necessary for reading dependencies generated by the odm-platform project (even though the project is public, authentication is required).
        * GITHUB_PASSWORD: Enter a personal password or app password for GitHub and make it private (click on the lock icon on the right).
        * AZURE_ODM_APP_CLIENT_ID: The client ID of the application created in step 6.
        * AZURE_ODM_APP_CLIENT_SECRET: Enter the client secret of the application created in step 6 and make it private (click on the lock icon on the right).
        * AZURE_TENANT_ID: Your Azure tenant ID.
      * Click on **Save**.
      * Click on **Pipeline permissions**, then on the three dots, and click on **Open access**.
   * Create a second group of variables and name it: **Azure-Config**.
      * Add the following variables:
        * backendServiceArm: The name of the service connection created in step 7 of this section.
        * backendAzureRmResourceGroupName: The name of an existing resource group in Azure where resources will be provisioned.
        * backendAzureRmStorageAccountName: The name of the storage account to be used for saving the Terraform state (if you don't have one, you can create it by following [this guide](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-portal))
        * backendAzureRmContainerName: The name of the container to be used for saving the Terraform state (if you have just created the storage account, follow [this guide](https://learn.microsoft.com/en-us/azure/storage/blobs/blob-containers-portal))
      * Click on **Save**.
      * Click on **Pipeline permissions**, then on the three dots, and click on **Open access**.
9. Modify the **config.json** file in the root of this repository to fill in the necessary configurations:
    * **tenant_id**: Your Azure tenant ID.
    * **region**: The region in which your resources will be deployed (e.g., "Germany West Central").
    * **subscription_id**: The ID of your Azure subscription.
    * **resource_group_name**: The name of the Azure resource group in which you want to deploy resources.


## ODM Platform deployment ##
With the environment prepared, we can deploy the components of the ODM Platform.

1. Launch the **odm-platform-infrastructure** pipeline on Azure DevOps. 
2. Once the execution is complete, view the details of the **Terraform Apply/Apply Terraform Plan** step and copy the IP found at the bottom of the execution log: **vm-public-endpoint**. 
3. Create an SSH service connection.
    * Go to the **Project Settings** page, located at the bottom left of Azure DevOps.
    * In the left menu, click on **Service connections** under the **Pipelines** section.
    * Click on **New service connection**, in the top right, and select SSH as the type. Enter the following values:
        * Host name: Enter the IP you copied earlier.
        * Port number: Leave the default, 22.
        * Username: odm
        * Password: 0p3nD@t@M3sh
        * Service connection name: odm-platform.
        * Check the option: Grant access permission to all pipelines.
4. Save and return to the pipelines page. Now run the **odm-platform-application** pipeline.
5. Finally, run the **odm-platform-executor-azdevops** pipeline.

At the end of the execution, if there were no errors, you should be able to reach the following endpoints, replacing the [IP] placeholder with the hostname used in step 3:

* ODM Platform Registry Module: http://[IP]:8001/api/v1/pp/registry/swagger-ui/index.html
* ODM DevOps Module: http://[IP]:8002/api/v1/pp/devops/swagger-ui/index.html

## Airline Data Product - Registration Phase ##

The next step is to register our Data Product in the ODM platform. Before doing so, let's input some configurations.

Open the **dp-demo-v1.0.0.json** file located in the **dp-demo-descriptor** folder and locate the following block:

```
"lifecycleInfo":{
         "provisionInfraDev":[
            {
               "service":{
                  "$href":"azure-devops"
               },
               "template":{
                  "specification":"spec",
                  "specificationVersion":"2.0",
                  "definition":{
                     "organization":"[organizationName]",
                     "project":"[projectName]",
                     "pipelineId":"[pipelineID]",
                     "branch":"master"
                  }
               },
               "configurations":{
                  "params":{
                     "callbackBaseURL":"http://[IP]:8002/api/v1/pp/devops"
                  },
                  "stagesToSkip":[
                     
                  ]
               }
            }
         ],
         "deployAppDev":[
            {
               "service":{
                  "$href":"azure-devops"
               },
               "template":{
                  "specification":"spec",
                  "specificationVersion":"2.0",
                  "definition":{
                     "organization":"[organizationName]",
                     "project":"[projectName]",
                     "pipelineId":"[pipelineID]",
                     "branch":"master"
                  }
               },
               "configurations":{
                  "params":{
                     "callbackBaseURL":"http://[IP]:8002/api/v1/pp/devops"
                  },
                  "stagesToSkip":[
                     
                  ]
               }
            }
         ]
      }
```

Replace the following placeholders with the specific values from your Azure DevOps:

* [organizationName]: the name of your organization in Azure DevOps.
* [projectName]: the name of the project where you created the pipelines.
* [pipelineID]: the ID of the specific pipeline; for the **provisionInfraDev** block, insert the ID of the **odm-demo-infrastructure** pipeline, and for the **deployAppDev** block, insert the ID of the **odm-demo-application** pipeline.
* [IP]: enter the value used as the hostname in the configuration of the SSH service connection. [Go to ODM Platform deployment instructions section](####-ODM-Platform-deployment-instructions-####)

We are now ready to register the Data Product in the ODM Platform. Open a terminal in the same folder as this README and execute the following commands, replacing the [IP] placeholder with the value used in the previous step.

1. The first step is to create the Data Product by providing some basic information. Execute the following cURL command:

```
curl -X 'POST' \
  'http://[IP]:8001/api/v1/pp/registry/products' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/vnd.odmp.v1+json' \
  -d "@dp-demo-descriptor/dp-demo.json"
```

2. Create a new version of the Data Product:

```
curl -X 'POST' \
  'http://[IP]:8001/api/v1/pp/registry/products/0979883d-dda1-36ab-8b1f-699e86158834/versions' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/vnd.odmp.v1+json' \
  -d "@dp-demo-descriptor/dp-demo-v1.0.0.json"
```

At this point, our Data Product has been registered in the ODM platform, and we can begin managing its lifecycle.

## Airline Data Product - Deployment Phase ##

Within the definition of the Airline Data Product (dp-demo-v1.0.0.json), you'll find, in the **Lifecycle** block, two main activities: **provisionInfraDev** and **deployAppDev**. The first one will deploy the necessary infrastructure for the Data Product, while the second will deploy the application that exposes the REST APIs on the newly created infrastructure.

Let's start with the **provisionInfraDev** activity:

1. Register the activity:

```
curl -X 'POST' \
  'http://[IP]:8002/api/v1/pp/devops/activities' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/vnd.odmp.v1+json' \
  -d "@dp-demo-descriptor/dp-demo-v1.0.0-activity-1.json"
```
2. Start the activity:

```
curl -X 'PATCH' \
  'http://[IP]:8002/api/v1/pp/devops/activities/1/status?action=START' \
  -H 'accept: application/json'
```

At this point, if you go back to Azure DevOps, you should see the **odm-demo-infrastructure** pipeline running.

* Once the pipeline is complete, view the details of the **Terraform Apply** step and copy the IP found at the bottom of the execution log: **vm-public-endpoint**.
* Create a second SSH service connection as done [in this paragraph](####-ODM-Platform-deployment-instructions-####), specifying the following values:
    * Host name: enter the IP you just copied.
    * Port number: leave the default, 22.
    * Username: airline
    * Password: @1rl1n3D3m0!
    * Service connection name: odm-demo-airline
    * Check the option: Grant access permission to all pipelines.

Now let's move on to the second and last activity of our Data Product, **deployAppDev**:
* Register the activity:

```
curl -X 'POST' \
  'http://[IP]:8002/api/v1/pp/devops/activities' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/vnd.odmp.v1+json' \
  -d "@dp-demo-descriptor/dp-demo-v1.0.0-activity-2.json"
```
* Start the activity:

```
curl -X 'PATCH' \
  'http://[IP]:8002/api/v1/pp/devops/activities/2/status?action=START' \
  -H 'accept: application/json'
```

At this point, if you go back to Azure DevOps, you should see the **odm-demo-application** pipeline running.

Once the pipeline is finished, you have completed the provisioning of the Airline Data Product, and you can start querying the exposed interfaces. As described initially, the Data Product exposes two interfaces, a REST API, and a SQL one.

* The first one exposes a REST API that returns, for a specific airline, the most frequent routes. Remember to replace the [IP] placeholder here with the value used in the previous step:

```
curl -X 'GET' \
  'http://[IP]:8080/api/v1/airline/2B/getTop3FrequentFlights' \
  -H 'accept: */*'
```

You should receive a response similar to this:

```
[
  {
    "airlineCode": "2B",
    "aptOrg": "VCE",
    "aptDst": "TIA",
    "fltFreq": 87
  },
  {
    "airlineCode": "2B",
    "aptOrg": "TIA",
    "aptDst": "VRN",
    "fltFreq": 87
  },
  {
    "airlineCode": "2B",
    "aptOrg": "TIA",
    "aptDst": "VCE",
    "fltFreq": 87
  }
]
```

Congratulations! You have successfully deployed your first Data Product.

## Housekeeping ##
To delete all the resources created in this guide, navigate to the **infrastructure** folder and execute the following commands, replacing the placeholders with the values from the configuration used in this demo.

Note: You'll need to log in to the Azure CLI, configuring the environment used for this demo.

```
terraform init -reconfigure -backend-config=storage_account_name=[storage_account_name] -backend-config=container_name=[container_name] -backend-config=key=odm-platform/azuredevops.terraform.tfstate -backend-config=resource_group_name=[resource_group_name]

terraform destroy
```

Perform the same operations in the **odm-platform-infra** folder, replacing the placeholders where necessary.

```
terraform init -reconfigure -backend-config=storage_account_name=[storage_account_name] -backend-config=container_name=[container_name] -backend-config=key=airline-demo/azuredevops.terraform.tfstate -backend-config=resource_group_name=[resource_group_name]

terraform destroy
```

## Who do I talk to? ##

* Giandomenico Avelluto
* Quantyca S.p.A