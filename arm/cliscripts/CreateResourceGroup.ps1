$resourceGroupName = $OctopusParameters["Global.Web.ResourceGroup.Name"]
$resourceGroupLocation = $OctopusParameters["Project.Web.Location"]

Write-Highlight "ResourceGroupName: $resourceGroupName"
Write-Highlight "ResourceGroupLocation: $resourceGroupLocation"

Try {
	Get-AzureRmResourceGroup -Name $resourceGroupName    
    $createResourceGroup = $false
} Catch {
	$createResourceGroup = $true
}

if ($createResourceGroup -eq $true){
	New-AzureRmResourceGroup -Name $resourceGroupName -Location "$resourceGroupLocation"    
}