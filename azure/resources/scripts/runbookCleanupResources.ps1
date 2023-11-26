Param
(
  [Parameter (Mandatory= $true)]
  [Array] $resourceGroups,

  [Parameter (Mandatory= $true)]
  [String] $identity
)

# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

# Connect to Azure with user-assigned managed identity
$AzureContext = (Connect-AzAccount -Identity -AccountId $identity).context

# set and store context
$AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext

$allResourceGroups = Get-AzResourceGroup

foreach ($group in $allResourceGroups){
  if($resourceGroups -contains $group.ResourceGroupName){
    write-output "Resource Group $($group.ResourceGroupName) will not be deleted"
  }
  else{
    Remove-AzResourceGroup -Name $($group.ResourceGroupName) -Force
  }
}
