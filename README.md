# TEKNOLOGI.NL

## GitHub Actions secrets

### TEKNOLOGI
- BICEP_GITHUB_ACTIONS_TEKNOLOGI

Contributor and User Access administrator rights on subscription
Also used to retrieve secrets from KeyVault for the GitHub Actions workflow

## DNS
The DNS zone teknologi.nl must have the nameservers configured to Azure DNS before deploying the infrastructure.


# AKS

## GitHub Actions secrets

### TEKNOLOGI
- BICEP_GITHUB_ACTIONS_TEKNOLOGI

Owner rights on subscription
Also used to retrieve secrets from KeyVault for the GitHub Actions workflow

### CLOUD
- BICEP_GITHUB_ACTIONS_CLOUD

Contributor and User Access administrator rights on subscription
Also used to retrieve secrets from KeyVault for the GitHub Actions workflow


## Configuration
After deploying the resources for the AKS cluster, the following components need to be configured.

### Service Principal
The Web UI of ArgoCD provides SSO, which enables authentication and authorization of users. To enable this feature, an `App Registration` needs to be created in the Active Directory of the Tenant where the Subscription and Resource Groups are created in. This can be done with the following steps:
1. Log in to the Azure Portal
2. Navigate to Azure Active Directory in the correct Tenant
3. Create an App Registration.
> **_NOTE:_** The callback address should be the /auth/callback endpoint of your Argo CD URL (e.g. https://argocd.example.com/auth/callback).
4. Once created, generate a Client Secret using the menu-item `Certificates & Secretes`. Store this secret in keyVault (SsoServicePrincipalClientSecret)
5. Add `groups` group claim. This is used by ArgoCD to authorize users after they have been authenticated. Navigate to `Token configuration` and add a `groups claim`. Add the `Group ID` claim to ID and Access token.

### DNS
The DNS records for ArgoCD and Grafana must be setup and point to the Kubernetes API server public IP.

##################################################################################################################

## Letsencrypt Certificate Manager
For development purposes Letsencrypt can be used to automatically assign R3 certificates on specified ingresses to allow HTTPS traffic without buying a (wildcard) SSL certificate. This is done by installing the `cert-manager` Helm chart provided by Jetstack. A `ClusterIssuer` resource object is deployed which specifies Letsencrypt as the ACME server.
To enable this feature on an Ingress, the Ingress should contain the following annotation:
```
cert-manager.io/cluster-issuer: letsencrypt-prod
```
Once set, the Pods in the `cert-manager` namespace detect the configuration change, automatically issue a certificate, and bind it to the Ingress.
> Ref: https://github.com/cert-manager/cert-manager

## NGINX Ingress Controller
This installs an NGINX deployment internally. In this configuration, a public endpoint is created which routes all incoming traffic directly to the cluster where the SSL offloading and URL routing is done. Although the AGIC is recommended in a production environment, the NGINX Ingress Controller is production ready too. However, the application in the cluster is not protected by a Web Application Firewall.

> Ref: https://github.com/kubernetes/ingress-nginx

## GitOps Operator
As an extension to Infrastructure-As-Code for the Azure Resources, GitOps can be used to store the cluster's configuration in a Git repository in a declaritive way. This is done by adding Kubernetes resources as YAML configuration files to this Git repository, which will automatically be created in the cluster by a Gitops operator as shown in the image below.

In this case, and in this template, ArgoCD is used as the Gitops operator, since it exposes a really intuitive User Interface.