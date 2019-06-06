## This should use the Run an Azure PowerShell Script step, not the generic run a script step!

$OctopusURL = $OctopusParameters["Global.Base.Url"]
$APIKey = $OctopusParameters["Global.Api.Key"]
$SpaceId = $OctopusParameters["Octopus.Space.Id"]
$environmentName = $OctopusParameters["Octopus.Environment.Name"]
$accountId = $OctopusParameters["Octopus.Action.Azure.AccountId"]
$environmentId = $OctopusParameters["Octopus.Environment.Id"]
$roleList = $OctopusParameters["Project.Web.Role.List"]
$resourceGroupName = $OctopusParameters["Global.Web.ResourceGroup.Name"]
$webAppName = $OctopusParameters["Global.Application.Name"]
$tenantId = $OctopusParameters["Octopus.Deployment.Tenant.Id"]

$header = @{ "X-Octopus-ApiKey" = $APIKey }

Write-Host "Get a list of all machine policies"
$machinePolicies = (Invoke-RestMethod "$OctopusUrl/api/$SpaceId/machinepolicies?skip=0&take=1000" -Headers $header)
$machinePolicyId = $null

foreach ($machinePolicy in $machinePolicies.Items)
{
    if ($machinePolicy.Name -like "*$environmentName*")
    {
        Write-Host "Found machine policy"
        $machinePolicyId = $machinePolicy.Id        
    }
}

$existingTargets = (Invoke-RestMethod "$OctopusUrl/api/$SpaceId/machines?skip=0&take=1000" -Headers $header)
$targetExists = $false

foreach($target in $existingTargets.Items)
{
    if ($target.Name -eq $webAppName)
    {
        $targetExists = $true
        break
    }
}

if ($targetExists -eq $false)
{
    $azureWebAppRegistration = @{
        "Id" = $null
        "MachinePolicyId" = $machinePolicyId
        "Name" = $webAppName
        "IsDisabled" = $false
        "HealthStatus" = "Unknown"
        "HasLatestCalamari" = $true
        "StatusSummary" = $null
        "IsInProcess" = $true
        "Endpoint" = @{
        "Id" = $null
        "CommunicationStyle" = "AzureWebApp"
        "Links" = $null
        "AccountId" = $accountId
        "ResourceGroupName" = $resourceGroupName
        "WebAppName" = $webAppName
        }
        "Links" = $null
        "TenantedDeploymentParticipation" = "Tenanted"
        "Roles" = $roleList -split ","    
        "EnvironmentIds" = @($environmentId)    
        "TenantIds" = @($tenantId)
        "TenantTags" = @()
    }

    $bodyAsJson = $azureWebAppRegistration | ConvertTo-Json

    $addMachineResponse = (Invoke-RestMethod "$OctopusUrl/api/$SpaceId/machines" -Headers $header -Method Post -Body $bodyAsJson -ContentType "application/json")

    Write-Host "Machine add response $addMachineResponse"
}
else {
    Write-Host "Target is already registered with Octopus"
}