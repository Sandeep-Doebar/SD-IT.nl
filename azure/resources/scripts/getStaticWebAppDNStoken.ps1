param (
    [string]$subscriptionId,    
    [string]$resourceGroupName,
    [string]$staticSiteName,
    [string]$customDomainName
)

$maxRetries = 5
$retryDelay = 2 # in minutes
$validationToken = $null
$isReady = $false

# Sleep for 3 minutes before making the requests
# Start-Sleep -Seconds (3 * 60)

for ($attempt = 1; $attempt -le $maxRetries; $attempt++) {
    Write-Host "Attempt $attempt of $maxRetries"
    try {
        # Make the Azure REST API call to get the validation token
        $response = Invoke-AzRestMethod -Uri "https://management.azure.com/subscriptions/$($subscriptionId)/resourceGroups/$($resourceGroupName)/providers/Microsoft.Web/staticSites/$($staticSiteName)/customDomains/$($customDomainName)?api-version=2020-12-01"
        $response 

        if($response.StatusCode -eq 200){
            $validationToken = ($response.Content | ConvertFrom-Json).properties.validationToken
            $status = ($response.Content | ConvertFrom-Json).properties.status 
            # If validationToken is found, break out of the loop
            if ($null -ne $validationToken) {
                Write-Host "Validation token found: $validationToken"
                break
            }
            elseif($status -eq "Ready"){
                Write-Host "Domain already has been validated"
                $validationToken = ''
                $isReady = $true
                break
            }
        }
        else{
            Write-Host "Retrying in $retryDelay minutes..."
            Start-Sleep -Seconds ($retryDelay * 60)
        }
    } catch {
        Write-Host "Error encountered: $_"
        Break
    }   
}

$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs['validationToken'] = $validationToken
$DeploymentScriptOutputs['isReady'] = $isReady