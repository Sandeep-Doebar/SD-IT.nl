    $resourceGroup = "HelloWorld"

    # Ensures you do not inherit an AzContext in your runbook
    Disable-AzContextAutosave -Scope Process

    # Connect to Azure with system-assigned managed identity
    Connect-AzAccount -Identity -AccountId 4f0f7096-2a8f-417a-9f96-fbd0cdf4c12c

    # set and store context
    Get-AzResourceGroup -Name $resourceGroup  | Remove-AzResourceGroup -Force