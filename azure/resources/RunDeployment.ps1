<#
az login 
##Deploy Teknologi infra resources
.\RunDeployment.ps1 -configFile "..\configs\main-tst.jsonc"
.\RunDeployment.ps1 -configFile "..\configs\main-prd.jsonc"

##Deploy AKS resources
.\RunDeployment.ps1 -configFile "..\configs\aks-tst.jsonc" -deployAKS $true -deployMain $false
.\RunDeployment.ps1 -configFile "..\configs\aks-prd.jsonc" -deployAKS $true -deployMain $false
#>

#Parameters
[CmdletBinding(PositionalBinding = $False)]
param (
    [string]$configFile,
    [string]$bicepMainFile = "main.bicep",
    [string]$bicepAKSFile = "aks.bicep",
    [boolean]$deployMain = $true,
    [boolean]$deployAKS = $false
)

#Stop script if try - catch failes
$ErrorActionPreference = "Stop"

$jsonc = Get-Content -Path $configFile -Raw
$json = $jsonc -replace '(?m)(?<=^([^"]|"[^"]*")*)//.*' -replace '(?ms)/\*.*?\*/'
$json | Out-File -FilePath ./configtemp.json -Encoding utf8
$config = Get-Content ./configtemp.json -Raw | ConvertFrom-Json -Depth 100

if($deployMain){
    if(Test-Path -Path "$($PSScriptRoot)/$($bicepMainFile)"){
        az deployment sub create `
            --subscription $config.subscriptionId `
            --location $config.location `
            --template-file "$($PSScriptRoot)/$($bicepMainFile)" `
            --parameters "config=`@./configtemp.json"
        if (!$?) {
            throw "Unable to deploy resources"
        }
    }
}    

if($deployAKS){
    if(Test-Path -Path "$($PSScriptRoot)/$($bicepAKSFile)"){
        az deployment sub create `
        --subscription $config.subscriptionId `
        --location $config.location `
        --template-file "$($PSScriptRoot)/$($bicepAKSFile)" `
        --parameters "config=`@./configtemp.json"
        
        if (!$?) {
            throw "Unable to deploy resources"
        }
    }    
}

Remove-Item ./configtemp.json