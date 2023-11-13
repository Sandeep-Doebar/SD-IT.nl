# From code to deployment!
Creates an initial deployment that contains a deployment script that will automatically delete a ResourceGroup each day as a failsafe for testing

Creates an AKS cluster in Azure through IaC with bicep and github action.

#Setup
 Github Action for Pipeline
 Bicep for IaC on Azure
 Powershell to start Bicep modules
 
# Bicep structure:

.jsonc for configfile
main.bicep
modules > main.bicep + modules

**Explanation modulair build up of Bicep:
**
The jsonc contains all the parameters used within the deployment. The idea behind this is that only the jsonc file needs to be change to change the deployment (for another tenant, resourcegroup or other parameters).  Through the rundeployment script, the configfile gets loaded in to the main.bicep file which uses the parameters defined within the .jsonc file. The main bicep files refers to the modules found under main-modules. The main-modules folder contains the different modules(or resources) which will be deployed. Each module folder contains a main.bicep file and another module folder that contains a single or multiple resource.bicep files. The resource.bicep files contains the api version and actual deployment parameters of the deployment. The top level main.bicep calls upon each main.bicep from each module folder, which will call upon each resource.bicep from its own module folder. This way the deployment has been made modular and easy to replicate/reuse. 
