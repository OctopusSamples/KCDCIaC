$resourceGroup = $OctopusParameters["Global.Web.ResourceGroup.Name"]
Remove-AzureRMResourceGroup -Name $resourceGroup -Force