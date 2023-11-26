Param
(
  [Parameter (Mandatory= $true)]
  [string] $managementResourceGroup,

  [Parameter (Mandatory= $true)]
  [string] $aksResourceGroup,

  [Parameter (Mandatory= $true)]
  [string] $identity
)

# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

# Connect to Azure with user-assigned managed identity
$AzureContext = (Connect-AzAccount -Identity -AccountId $identity).context

# set and store context
$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext

$allResourceGroups = Get-AzResourceGroup

$resourceGroups = @($aksResourceGroup, $managementResourceGroup)

foreach ($group in $allResourceGroups){
  if($resourceGroups -contains $group.ResourceGroupName){
    write-output "Resource Group $($group.ResourceGroupName) will not be deleted"
  }
  else{
    Remove-AzResourceGroup -Name $($group.ResourceGroupName) -Force
  }
}
