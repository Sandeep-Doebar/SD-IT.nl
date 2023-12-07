    $resourceGroup = "teknologi-eur1-main-tst-rg"

    # Ensures you do not inherit an AzContext in your runbook
    Disable-AzContextAutosave -Scope Process

    # Connect to Azure with system-assigned managed identity
    Connect-AzAccount -Identity -AccountId ab09a113-8c66-436d-b0ad-8919a75d7c32

    # set and store context
    Get-AzResourceGroup -Name $resourceGroup  | Remove-AzResourceGroup -Force