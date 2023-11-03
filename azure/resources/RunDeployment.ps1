<#
az login 
.\RunDeployment.ps1
#>

#Variables
[CmdletBinding(PositionalBinding = $False)]
param (
    [string]$configFile = ".\configs\config.jsonc",
    [string]$bicepMainFile = "main.bicep",
    [string]$bicepInitFile = "init.bicep",
    [boolean]$runBicepInit = $false
)

#Stop script if try- catch failes
$ErrorActionPreference = "Stop"

$jsonc = Get-Content -Path $configFile -Raw
$json = $jsonc -replace '(?m)(?<=^([^"]|"[^"]*")*)//.*' -replace '(?ms)/\*.*?\*/'
$json | Out-File -FilePath ./configtemp.json -Encoding utf8

$Config = Get-Content ./configtemp.json -Raw | ConvertFrom-Json -Depth 100
Remove-Item ./configtemp.json
$getResources = az resource list -g $Config.ResourceGroupName --query "[].name"

$TempFile = (New-TemporaryFile).FullName
$getResources | Out-File -FilePath $TempFile
if (!$?) {
    throw "Unable to retrieve existing resources"
}

$Components = New-Object System.Collections.Generic.List[System.String]

[System.Action[string, action]] $ExecuteDeployment = {
    param($DeploymentName, $Action)

    Write-Host "Deploying: ${DeploymentName}" -ForegroundColor Cyan

    try {
        $Action.invoke()
    }
    catch {
        Write-Host "Unable to deploy '${DeploymentName}':" -ForegroundColor Red
        Throw $_ 
    }
    $Components.Add($DeploymentName)
}

#
#Deploy Bicep Resources (init)
#
if($runBicepInit){
    if(Test-Path -Path "$($PSScriptRoot)/$($bicepInitFile)"){
        $ExecuteDeployment.invoke("Bicep resources", {
            az deployment group create `
                --resource-group $Config.ResourceGroupName `
                --subscription $Config.SubscriptionId `
                --template-file "$($PSScriptRoot)/$($bicepInitFile)" `
                --parameters "config=`@./configtemp.json" "existingResources=`@$($TempFile)"
        
            if (!$?) {
                throw "Unable to deploy resources"
            }
        })    
    }
}

#
#Deploy Bicep Resources (main)
#
$ExecuteDeployment.invoke("Bicep resources", {
    az deployment group create `
        --resource-group $Config.ResourceGroupName `
        --subscription $Config.SubscriptionId `
        --template-file "$($PSScriptRoot)/$($bicepMainFile)" `
        --parameters "config=`@./configtemp.json" "existingResources=`@$($TempFile)"

    if (!$?) {
        throw "Unable to deploy resources"
    }
})

Write-Host 'Deployment finished. Installed components:' -ForegroundColor Green
$Components