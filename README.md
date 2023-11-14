# README #

In questa demo andiamo a esporre un Data Product composto da due interfacce con i relativi data contract:

* SQL Interface: viene esposta una connessione via JDBC a un database MySQL
* API REST Interface: viene esposta una API REST per l'interrogazione dei dati

## Demo Requirements ##
 
 * Azure Subscription
 * Access to Azure DevOps
   * [Azure DevOps Terraform extension](https://marketplace.visualstudio.com/items?itemName=JasonBJohnson.azure-pipelines-tasks-terraform) installed
 * Terraform installed
 * Azure CLI installed
 * cURL or Postman installed

## How do I get set up? ##

### Summary of set up ###

La demo prevede l'esecuzione della OpenDataMesh (aka ODM) Plaform in ambiente Azure e la registrazione del Data Product contenuto in questo repository di demo e infine il deploy.


#### Prerequisites ####

Per effettuare il rilascio della ODM Platform, potete seguire questa procedura step-by-step:

1. Accedere ad Azure DevOps
2. Se non è già presente, creare un nuovo progetto
3. Entrare nella sezione Repository (si trova nel menu a sinistra), e cliccare su "Importa reporitory". Selezionare il protocollo Git e inserire il seguente link: 
    * https://github.com/opendatamesh-initiative/odm-platform.git
4. Ripetere lo step 3 per i seguenti repositories:
    * https://github.com/opendatamesh-initiative/odm-platform-up-services-executor-azuredevops.git
    * TO-BE merged repo
5. Nella sezione dedicata alle pipeline (sempre nel menu a sinistra), cliccare su **Create Pipeline**.
    * La prima pipeline da creare è quella relativa al rilascio dell'infrastruttura sulla quale si appoggerà ODM Platform (la pipeline provisionerà una VM di tipo: Standard_A1_v2, 1CPU / 2GB RAM).
        * Nella sezione di connessione repository, scegliere quindi Azure Repo e selezionare il repository TBD
        * Nella sezione Configure, selezionare l'opzione Existing Azure Pipelines YAML file. Successivamente scegliere $master come branch e $path/odm-platform-infra/azure-pipelines.yml come puntamento al file yaml
        * Salvare la pipeline selezionando salva dal menu vicino la scritta "Run" (la pipeline verrà salvata ma non eseguita).
        * Modificare il nome della pipeline nel seguente modo: odm-platform-infrastructure
    * La seconda pipeline da creare serve per deployare ODM all'interno dell'infrastruttura creata dalla prima pipeline
        * Nella sezione di connessione repository, scegliere quindi Azure Repo e selezionare il repository odm-platform importato precedentemente
        * Nella sezione Configure, selezionare l'opzione Existing Azure Pipelines YAML file. Successivamente scegliere $main come branch e passare il seguente path: /azure-pipelines.yml 
        * Salvare la pipeline selezionando salva senza eseguire
        * Modificare il nome della pipeline nel seguente modo: odm-platform-application
    * La terza pipeline da creare serve per deployare l'executor Azure Devops di ODM, componente che si interfaccerà con il vostro Azure DevOps.
        * Nella sezione di connessione repository, scegliere quindi Azure Repo e selezionare il repository odm-platform-up-services-executor-azuredevops importato precedentemente
        * Nella sezione Configure, selezionare l'opzione Existing Azure Pipelines YAML file. Successivamente scegliere $main come branch e passare il seguente path: /azure-pipelines.yml 
        * Salvare la pipeline selezionando salva senza eseguire
        * Modificare il nome della pipeline nel seguente modo: odm-platform-executor-azdevops
    * La quarta pipeline da creare si occuperà di effettuare il provisioning dell'infrastruttura per la demo (la pipeline provisionerà una VM di tipo: Standard_A1_v2, 1CPU / 2GB RAM e un DB MySQL di tipo: B_Gen5_1).
        * Nella sezione di connessione repository, scegliere quindi Azure Repo e selezionare il repository TBD importato precedentemente
        * Nella sezione Configure, selezionare l'opzione Existing Azure Pipelines YAML file. Successivamente scegliere $master come branch e passare il seguente path: $path/infrastructure/azure-pipelines-infra.yml 
        * Salvare la pipeline selezionando salva senza eseguire
        * Modificare il nome della pipeline nel seguente modo: odm-demo-infrastructure
    * La quinta e ultima pipeline da creare serve per deployare l'applicazione che esporrà la REST API
        * Nella sezione di connessione repository, scegliere quindi Azure Repo e selezionare il repository TBD
        * Nella sezione Configure, selezionare l'opzione Existing Azure Pipelines YAML file. Successivamente scegliere $master come branch e passare il seguente path: $path/application/airlinedemo/azure-pipelines-app.yml
        * Salvare la pipeline selezionando salva senza eseguire.
        * Modificare il nome della pipeline nel seguente modo: odm-demo-application
6. Creare una application sul proprio Azure AD per poter gestire programmaticamente le pipelines:
    * seguire le indicazioni contenute [in questo documento](https://github.com/opendatamesh-initiative/odm-platform-up-services-executor-azuredevops), nella sezione: **Azure Environment**
7. Tornare su Azure DevOps e creare una service connection di tipo Azure Resource Manager
    * Entrare nella pagina di **Project Settings**, la trovate in basso a sinistra di Azure DevOps.
    * Nel menù a sinistra cliccate su **Service connections** sotto la sezione Pipelines.
    * Cliccare su **New service connection**, in alto a destra, e selezionare **Azure Resource Manager** come tipologia e **Workload Identity Federation** come metodo di autenticazione, infine inserite le seguenti configurazioni:
        * Scope level: scegliere **Subscription**
        * Subscription: selezionate il nome della vostra subscription Azure
        * Resource Group: selezionate il vostro resource group Azure
        * Service connection name: inserire **ODMServiceConnection**
        * Flaggare l'opzione: Grant access permission to all pipelines
8. Creare i seguenti gruppi di variabili andando nella sezione Library del menù di Azure DevOps:
   * Creare un gruppo di variabili e nominarlo: **ODM-Platform**
      * Aggiungere le seguenti variables: 
        * GITHUB_USERNAME: Necessario per leggere le dipendenze generate dal progetto odm-platform (nonostante il progetto sia pubblico è necessario autenticarsi)
        * GITHUB_PASSWORD: Inserire password personale o app password per github e renderla privata (cliccare sul lucchetto a destra)
        * AZURE_ODM_APP_CLIENT_ID: Il client id dell'applicazione creata allo step 6
        * AZURE_ODM_APP_CLIENT_SECRET: Inserire il client secret dell'applicazione creata allo step 6 e renderla privata (cliccare sul lucchetto a destra)
        * AZURE_TENANT_ID: il vostro azure tenant id
      * Cliccare su **Save**
      * Cliccare su **Pipeline permissions**, poi sui tre puntini e cliccare su **Open access**
   * Creare un secondo gruppo di variabili e nominarlo: **Azure-Config**
      * Aggiungere le seguenti variables: 
        * backendServiceArm: Il nome della service connection creata nello step 7 di questo paragrafo.
        * backendAzureRmResourceGroupName: il nome di una resource group esistente in Azure, nel quale verranno provisionate le risorse
        * backendAzureRmStorageAccountName: Il nome dello storage account da utilizzare per salvare lo stato di Terraform
        * backendAzureRmContainerName: Il nome del container da utilizzare per salvare lo stato di Terraform
      * Cliccare su **Save**
      * Cliccare su **Pipeline permissions**, poi sui tre puntini e cliccare su **Open access**
9. Modificare il file config.json presente nella root di questo repository andando a valorizzare le configurazioni necessarie:
    * **tenant_id**: l'id del vostro tenant Azure
    * **region**: la regione nella quale le vostre risorse saranno deployate (e.g. "Germany West Central")
    * **subscription_id**: l'id della vostra subscription Azure
    * **resource_group_name**: il nome del resource group Azure nel quale vorrete effettuare il deploy delle risorse


## ODM Platform deployment ##
Preparato l'ambiente, possiamo deployare i componenti della ODM Platform.

1. Lanciare su Azure DevOps la pipeline **odm-platform-infrastructure**
2. Completata l'esecuzione, visualizzare i dettagli dello step **Terraform Apply**/**Apply Terraform Plan** e copiare l'IP che trovate alla riga in fondo al log di esecuzione: vm-public-endpoint. 
3. Creare service connection ssh
    * Entrare nella pagina di **Project Settings**, la trovate in basso a sinistra di Azure DevOps.
    * Nel menù a sinistra cliccate su **Service connections** sotto la sezione Pipelines.
    * Cliccare su **New service connection**, in alto a destra, e selezionare SSH come tipologia e inserite i seguenti valori:
        * Host name: inserite l'IP che avete copiato precedentemente
        * Port number: lasciate il default, 22
        * Username: odm
        * Password: 0p3nD@t@M3sh
        * Service connection name: odm-platform
        * Flaggare l'opzione: Grant access permission to all pipelines
4. Salvare e tornare sulla pagina delle pipeline. Eseguire ora la pipeline **odm-platform-application**
5. Infine, eseguire la pipeline **odm-platform-executor-azdevops**

Alla fine dell'esecuzione, se non ci sono stati errori, dovreste poter raggiungere i seguenti endpoint, sostituendo il placeholder [IP] con l'hostname utilizzato nello step 3:

* ODM Platform Registry Module: http://[IP]:8001/api/v1/pp/registry/swagger-ui/index.html
* ODM DevOps Module: http://[IP]:8002/api/v1/pp/devops/swagger-ui/index.html

## Airline Data Product - Registration Phase ##

Il prossimo passo sarà registrare il nostro Data Product nella piattaforma ODM. Prima di farlo, andiamo a inserire alcune configurazioni.

Aprire il file **dp-demo-v1.0.0.json** contenuto nella cartella **dp-demo-descriptor** e individuare il seguente blocco:

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

Sostituire i seguenti placeholder con i valori specifici del vostro Azure DevOps:

* [organizationName]: nome della vostra oragnizzazione in Azure DevOps
* [projectName]: nome del progetto in cui avete creato le pipeline
* [pipelineID]: ID della pipeline specifica, nel blocco di **provisionInfraDev** andrà inserito l'ID della pipeline **odm-demo-infrastructure** mentre per il blocco **deployAppDev** andrà inserito l'ID della pipeline **odm-demo-application**
* [IP]: inserire il valore usato come hostname nella configurazione della service connection SSH. [Go to ODM Platform deployment instructions section](####-ODM-Platform-deployment-instructions-####)

Siamo pronti ora per effettuare la registrazione del Data Product nella ODM Platform. Aprire un terminale posizionandosi all'interno della stessa cartella di questo README ed eseguire le seguenti chiamate sostituendo il placeholder [IP] con il valore usato nel punto precedente.

1. Il primo step è creare il Data Product passando alcune informazioni base. Per farlo eseguire la seguente chiamata cURL:

```
curl -X 'POST' \
  'http://[IP]:8001/api/v1/pp/registry/products' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/vnd.odmp.v1+json' \
  -d "@dp-demo-descriptor/dp-demo.json"
```

2. Creare una nuova versione del Data Product:

```
curl -X 'POST' \
  'http://[IP]:8001/api/v1/pp/registry/products/0979883d-dda1-36ab-8b1f-699e86158834/versions' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/vnd.odmp.v1+json' \
  -d "@dp-demo-descriptor/dp-demo-v1.0.0.json"
```

A questo punto il nostro DP è stato registrato nella piattaforma ODM, possiamo quindi iniziare a gestirne il ciclo di vita. 

## Airline Data Product - Deployment Phase ##

All'interno della definizione del Data Product Airline (dp-demo-v1.0.0.json) troveremo, nel blocco di Lifecycle, due attività principali: **provisionInfraDev** e **deployAppDev**. La prima andrà a deployare l'infrastruttura necessaria per il Data Product, la seconda effettuerà il deploy dell'applicazione, che espone le API REST, sull'infrastruttura appena creata.

Partiamo dall'attività **provisionInfraDev**:

1. registrare l'attività:

```
curl -X 'POST' \
  'http://[IP]:8002/api/v1/pp/devops/activities' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/vnd.odmp.v1+json' \
  -d "@dp-demo-descriptor/dp-demo-v1.0.0-activity-1.json"
```
2. avviare l'attività:

```
curl -X 'PATCH' \
  'http://[IP]:8002/api/v1/pp/devops/activities/1/status?action=START' \
  -H 'accept: application/json'
```

A questo punto se tornate all'interno di Azure DevOps, dovreste vedere running la pipeline **odm-demo-infrastructure**.

* Completata la pipeline, visualizzare i dettagli dello step **Terraform Apply** e copiare l'IP che trovate alla riga in fondo al log di esecuzione: vm-public-endpoint.
* Creare una seconda service connection di tipo SSH come fatto [in questo paragrafo](####-ODM-Platform-deployment-instructions-####), specificando i seguenti valori:
    * Host name: inserite l'IP che avete appena copiato
    * Port number: lasciate il default, 22
    * Username: airline
    * Password: @1rl1n3D3m0!
    * Service connection name: odm-demo-airline
    * Flaggare l'opzione: Grant access permission to all pipelines

Passiamo alla seconda e ultima attività del nostro DP, **deployAppDev**:
* registrare l'attività:

```
curl -X 'POST' \
  'http://[IP]:8002/api/v1/pp/devops/activities' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/vnd.odmp.v1+json' \
  -d "@dp-demo-descriptor/dp-demo-v1.0.0-activity-2.json"
```
* avviare l'attività:

```
curl -X 'PATCH' \
  'http://[IP]:8002/api/v1/pp/devops/activities/2/status?action=START' \
  -H 'accept: application/json'
```

A questo punto se tornate all'interno di Azure DevOps, dovreste vedere running la pipeline **odm-demo-application**.

Conclusa la pipeline avremo completato il provisioning del Data Product Airline e potrete iniziare a interrogare le interfacce che espone. Come descritto inizialmente il Data Product espone due interfacce, una REST API e una SQL.

* La prima espone una REST API che restituisce, per una specifica linea aerea, le tratte più frequenti. Ricordarsi di sostituire anche qui il placeholder [IP] con il valore usato nel precedente step:

```
curl -X 'GET' \
  'http://[IP]:8080/api/v1/airline/2B/getTop3FrequentFlights' \
  -H 'accept: */*'
```

Dovreste ricevere una risposta simile a questa:

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

Congratulazioni!! Sei riuscito a deployate il tuo primo Data Product.

## Cleanup ##
Per cancellare tutte le risorse create in questa guida, posizionarsi all'interno della cartella **infrastructure** ed eseguire i seguenti comandi, sostituendo i placeholder, con i valori della configurazione usata in questa demo.

Nota: dovrete effettuare il login alla Azure CLI configurando l'ambiente usato per questa demo.

```
terraform init -reconfigure -backend-config=storage_account_name=[storage_account_name] -backend-config=container_name=[container_name] -backend-config=key=odm-platform/azuredevops.terraform.tfstate -backend-config=resource_group_name=[resource_group_name]

terraform destroy
```

Eseguire le stesse operazioni nella cartella **odm-platform-infra**, sostituendo sempre i placeholder dove necessario.

```
terraform init -reconfigure -backend-config=storage_account_name=[storage_account_name] -backend-config=container_name=[container_name] -backend-config=key=airline-demo/azuredevops.terraform.tfstate -backend-config=resource_group_name=[resource_group_name]

terraform destroy
```

## Who do I talk to? ##

* Giandomenico Avelluto
* Quantyca S.p.A