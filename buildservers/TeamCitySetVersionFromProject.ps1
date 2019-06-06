param(
    [string]$checkoutDirectory,
    [string]$projectPath,
    [string]$currentBranch,
    [string]$buildNumber,
    [string]$octopusUrl,
    [string]$octopusApiKey,
    [string]$octopusSpaceName,
    [string]$octopusProjectName    
)

Write-Host "CheckoutDirectory: $checkoutDirectory"
Write-Host "ProjectPath: $projectPath"
Write-Host "CurrentBranch: $currentBranch"
Write-Host "BuildNumber: $buildNumber"
Write-Host "OctopusUrl: $octopusUrl"
Write-Host "Octopus Space Name: $octopusSpaceName"
Write-Host "Octopus Project Name: $octopusProjectName"

$fullProjectPath = "$checkoutDirectory\$projectPath"

[xml]$projectDoc = Get-Content $fullProjectPath
$versionNumber = $projectDoc.Project.PropertyGroup.PackageVersion
Write-Host "Found the version number: $versionNumber"

$octopusVersionNumber = "$versionNumber.$buildNumber"
$octopusEnvironment = "Development"
$octopusChannel = "Default"
$octopusTenant = "Master"

if ($currentBranch -eq "refs/heads/master" -or $currentBranch -eq "master"){
    Write-Host "Master branch found, going to deploy to the master tenant and development environment"

    $commitMessage = git log -1 --pretty=oneline --abbrev-commit

    $commitMessage = "The commit message is: $commitMessage"

    if ($commitMessage -like "*Merge Pull Request*")
    {
        Write-Host "This commit was a result of a pull request, going to tear down the other branch"

        $indexOfSlash = $commitMessage.ToString().IndexOf('/')
        Write-Host "The index of the slash is $indexOfSlash"

        $mergedTenant = $commitMessage.SubString($commitMessage.IndexOf("/") + 1).replace("refs/heads/", "").replace(" ", "").replace("/", "-")
        Write-Host "The tenant name to clean-up is $mergedTenant"

        Write-Host "Get list of all spaces"

        $header = @{ "X-Octopus-ApiKey" = $octopusApiKey }

        Write-Host "Finding the space for this tenant"
        $spaceList = (Invoke-RestMethod "$OctopusUrl/api/spaces?skip=0&take=1000" -Headers $header)
        $spaceId = "Spaces-1"
        $projectId = $null
        $tenantId = $null
        $releaseId = $null

        foreach($space in $spaceList.Items)
        {
            if ($space.Name -eq $octopusSpaceName)
            {
                $spaceId = $space.Id
                break
            }
        }

        Write-Host "Space-Id found: $spaceId"

        $tenantList = (Invoke-RestMethod "$OctopusUrl/api/$spaceId/tenants?name=$mergedTenant&skip=0&take=1000" -Headers $header)
            
        foreach($tenant in $tenantList.Items)
        {
            if ($tenant.Name -eq $mergedTenant)
            {        
                $tenantId = $tenant.Id        
                Write-Host "The tenant we are going to be tearing down is $tenantId"
                        
                break
            }        
        }

        $projectList = (Invoke-RestMethod "$OctopusUrl/api/$spaceId/projects?name=$octopusProjectName&skip=0&take=1000" -Headers $header)

        foreach($project in $projectList.Items)
        {
            if ($project.Name -eq $octopusProjectName)
            {
                $projectId = $project.Id
                Write-Host "The project we are going to be sending the teardown command to $projectId"
            }
        }

        if ($tenantId -ne $null -and $projectId -ne $null)
        {
            $releaseList = (Invoke-RestMethod "$OctopusUrl/api/$spaceId/projects/$projectId/releases?name=$versionNumber&skip=0&take=1000" -Headers $header)

            foreach($release in $releaseList.Items)
            {
                $releaseVersion = $release.Version
                Write-Host "The release version is $releaseVersion"

                if ($releaseVersion -like "*$mergedTenant")
                {
                    $releaseId = $release.Id
                    Write-Host "The release we are going to be promoting to teardown is $releaseId"
                    break
                }
            }

            $tearDownEnvironmentId = (Invoke-RestMethod "$OctopusUrl/api/$spaceId/environments?name=TearDown&skip=0&take=1000" -Headers $header).Items[0].Id
            Write-Host "The teardown environmentId is $tearDownEnvironmentId"

            if ($releaseId -ne $null)
            {
                $bodyRaw = @{
                    EnvironmentId = "$tearDownEnvironmentId"
                    ExcludedMachineIds = @()
                    ForcePackageDownload = $False
                    ForcePackageRedeployment = $false
                    FormValues = @{}
                    QueueTime = $null
                    QueueTimeExpiry = $null
                    ReleaseId = "$releaseId"
                    SkipActions = @()
                    SpecificMachineIds = @()
                    TenantId = $tenantId
                    UseGuidedFailure = $false
                } 

                $bodyAsJson = $bodyRaw | ConvertTo-Json
                $tearDownDeployment = (Invoke-RestMethod "$OctopusURL/api/$SpaceId/deployments" -Headers $header -Method Post -Body $bodyAsJson -ContentType "application/json")
                Write-Host "The result of the teardown request is $tearDownDeployment"
            }
        }
    }
}
else{
    Write-Host "Development branch found"
    $octopusChannel = "Feature Branch"

    $octopusTenant = $currentBranch.replace("refs/heads/", "").replace(" ", "").replace("/", "-")
    $octopusVersionNumber = "$octopusVersionNumber-$octopusTenant"
    Write-Host "Get list of all spaces"

    $header = @{ "X-Octopus-ApiKey" = $octopusApiKey }
    
    Write-Host "Finding the space for this tenant"
    $spaceList = (Invoke-RestMethod "$OctopusUrl/api/spaces?skip=0&take=1000" -Headers $header)
    $spaceId = "Spaces-1"

    foreach($space in $spaceList.Items)
    {
        if ($space.Name -eq $octopusSpaceName)
        {
            $spaceId = $space.Id
            break
        }
    }

    Write-Host "Space-Id found: $spaceId"

    Write-Host "Getting the tenant template"
    $tenantTemplate = (Invoke-RestMethod "$OctopusUrl/api/$spaceId/tenants?name=tenant-template&skip=0&take=1000" -Headers $header).Items[0]
    $tenantList = (Invoke-RestMethod "$OctopusUrl/api/$spaceId/tenants?name=$octopusTenant&skip=0&take=1000" -Headers $header)
    $tenantToUpdate = $null
        
    foreach($tenant in $tenantList.Items)
    {
        if ($tenant.Name -eq $octopusTenant)
        {
            Write-Host "Found the tenant, updating it to match the template"
            $tenantToUpdate = $tenant  
            $tenantId = $tenant.Id
            $tenantToUpdate.ProjectEnvironments = $tenantTemplate.ProjectEnvironments
            $tenantToUpdate.TenantTags = $tenantTemplate.TenantTags          

            $tenantBody = $tenantToUpdate | ConvertTo-Json
            $tenantUpdateResult = (Invoke-RestMethod "$OctopusUrl/api/$spaceId/tenants/$tenantId" -Headers $header -Method Put -Body $tenantBody -ContentType "Application/Json")

            Write-Host "Tenant update result $tenantUpdateResult"
            break
        }        
    }

    if ($tenantToUpdate -eq $null)
    {
        Write-Host "New tenant detected, creating a new tenant from the template"
        $tenantToUpdate = $tenantTemplate
        $tenantToUpdate.Id = $null
        $tenantToUpdate.Name = $octopusTenant

        $tenantBody = $tenantToUpdate | ConvertTo-Json
        $tenantCreateResult = (Invoke-RestMethod "$OctopusUrl/api/$spaceId/tenants" -Headers $header -Method POST -Body $tenantBody -ContentType "Application/Json")

        Write-Host "Tenant create result $tenantCreateResult"
    }
}

"##teamcity[setParameter name='env.octopus.release.number' value='$octopusVersionNumber']"
"##teamcity[setParameter name='env.octopus.environment.name' value='$octopusEnvironment']"
"##teamcity[setParameter name='env.octopus.channel.name' value='$octopusChannel']"
"##teamcity[setParameter name='env.octopus.tenant.name' value='$octopusTenant']"