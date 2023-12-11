<#
az login 
.\RunDeployment.ps1 -initConfigFile "..\configs\init-tst.jsonc" -mainConfigFile "..\configs\main-tst.jsonc"
#>

#Variables

[CmdletBinding(PositionalBinding = $False)]
param (
    [string]$initConfigFile,
    [string]$mainConfigFile,
    [string]$sshPublicKey,
    [string]$bicepMainFile = "main.bicep",
    [string]$bicepInitFile = "init.bicep",
    [boolean]$runBicepInit = $true
)

#Stop script if try- catch failes
$ErrorActionPreference = "Stop"
$initJsonc = Get-Content -Path $initConfigFile -Raw
$initJson = $initJsonc -replace '(?m)(?<=^([^"]|"[^"]*")*)//.*' -replace '(?ms)/\*.*?\*/'
$initJson | Out-File -FilePath ./initconfigtemp.json -Encoding utf8

$initConfig = Get-Content ./initconfigtemp.json -Raw | ConvertFrom-Json -Depth 100

$jsonc = Get-Content -Path $mainConfigFile -Raw
$json = $jsonc -replace '(?m)(?<=^([^"]|"[^"]*")*)//.*' -replace '(?ms)/\*.*?\*/'
$json | Out-File -FilePath ./configtemp.json -Encoding utf8

$Config = Get-Content ./configtemp.json -Raw | ConvertFrom-Json -Depth 100

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
#Create init-resourcegroup if not existing
#

Get-AzResourceGroup -Name $initConfig.ResourceGroupName -ErrorVariable notPresent -ErrorAction SilentlyContinue

if ($notPresent)
{
    try {
        New-AzResourceGroup -Name $initConfig.ResourceGroupName -Location "France Central"
        Write-Host "Creating resourceGroup $($initConfig.ResourceGroupName)... "-ForegroundColor Green
        
        }
    catch {
        Write-Host "Unable to deploy resourceGroup $($initConfig.ResourceGroupName)': exiting" -ForegroundColor Red
        Throw $_ 
        exit
    }
}
else
{
        Write-Host "ResourceGroup $($initConfig.ResourceGroupName) already exists, continuing:" -ForegroundColor Yellow
}

#
#Create main-resourcegroup if not existing
#

Get-AzResourceGroup -Name $Config.ResourceGroupName -ErrorVariable notPresent -ErrorAction SilentlyContinue

if ($notPresent)
{
    try {
        New-AzResourceGroup -Name $Config.ResourceGroupName -Location "France Central"
        Write-Host "Creating resourceGroup $($Config.ResourceGroupName)... "-ForegroundColor Green
        
        }
    catch {
        Write-Host "Unable to deploy resourceGroup $($Config.ResourceGroupName)': exiting" -ForegroundColor Red
        Throw $_ 
        exit
    }
}
else
{
        Write-Host "ResourceGroup $($Config.ResourceGroupName) already exists, continuing:" -ForegroundColor Yellow
}

#
#check registratie
#

$msoperationsmangement = az provider show -n Microsoft.OperationsManagement | ConvertFrom-Json
$msoperationsmangement = $msoperationsmangement.registrationstate

if ($msoperationsmangement -eq "NotRegistered")
{
    az provider register --namespace Microsoft.OperationsManagement
}

$msOperationalInsights = az provider show -n Microsoft.OperationalInsights | ConvertFrom-Json
$msOperationalInsights = $msOperationalInsights.registrationstate

if ($msOperationalInsights -eq "NotRegistered")
{
    az provider register --namespace Microsoft.msOperationalInsights
}

#
#Deploy Bicep Resources (init)
#
if($runBicepInit){
    if(Test-Path -Path "$($PSScriptRoot)/$($bicepInitFile)"){
        $ExecuteDeployment.invoke("Bicep resources", {
            az deployment group create `
                --resource-group $initConfig.ResourceGroupName `
                --subscription $initConfig.SubscriptionId `
                --template-file "$($PSScriptRoot)/$($bicepInitFile)" `
                --parameters "config=`@./initconfigtemp.json" 
        
            if (!$?) {
                throw "Unable to deploy resources"
            }
        })    
    }
}

#
#Upload runbook
#
if($runBicepInit){
$clid = (Get-AzUserAssignedIdentity -ResourceGroupName $initConfig.ResourceGroupName -Name $initConfig.managedIdentities.name).clientid  
$rg = $Config.ResourceGroupName
$aa = $initConfig.automationAccounts.name
$rbname = $initConfig.automationAccounts.runbook.name
$sjn = $initConfig.automationAccounts.schedule.name
$runbooknps = $initConfig.automationAccounts.runbook.runbookps 
$path = ".\scripts\$runbooknps"
new-item $path -Force -ItemType File -Value "
# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

# Connect to Azure with system-assigned managed identity
Connect-AzAccount -Identity -AccountId $clid

# set and store context
Get-AzResourceGroup -Name $rg  | Remove-AzResourceGroup -Force
"
Import-AzAutomationRunbook -AutomationAccountName $aa -Name $rbname -Path $path -Published -ResourceGroupName $initConfig.ResourceGroupName -Type PowerShell -Force
Register-AzAutomationScheduledRunbook -AutomationAccountName $aa -Name $rbname -ResourceGroupName $initConfig.ResourceGroupName -ScheduleName $sjn
}

$key = az sshkey show --name "mySSHKey" --resource-group $Config.ResourceGroupName | ConvertFrom-Json
if ($key -eq $null)
{
start-sleep -Seconds 60    
az sshkey create --name "mySSHKey" --resource-group $Config.ResourceGroupName 
$key = az sshkey show --name "mySSHKey" --resource-group $Config.ResourceGroupName | ConvertFrom-Json    
}
else
{
    write-host "using existing ssh public key..."
}
$sshPublicKey = $key.PublicKey

#
#Deploy Bicep Resources (main)
#
$ExecuteDeployment.invoke("Bicep resources", {
    az deployment group create `
        --resource-group $Config.ResourceGroupName `
        --subscription $Config.SubscriptionId `
        --template-file "$($PSScriptRoot)/$($bicepMainFile)" `
        --parameters "config=`@./configtemp.json" "sshPublicKey=$sshPublicKey"

    if (!$?) {
        throw "Unable to deploy resources"
    }
})

Write-Host 'Deployment finished. Installed components:' -ForegroundColor Green
$Components
Remove-Item .\scripts\runbookDeleteResources.ps1
Remove-Item ./initconfigtemp.json
Remove-Item ./configtemp.json