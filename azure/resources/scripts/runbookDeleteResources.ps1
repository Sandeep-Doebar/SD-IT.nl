
# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

# Connect to Azure with system-assigned managed identity
Connect-AzAccount -Identity -AccountId a92ded5f-6277-4c95-b681-3221083f945a

# set and store context
Get-AzResourceGroup -Name teknologi-eur1-main-tst-rg  | Remove-AzResourceGroup -Force
