$resourceGroupName = $OctopusParameters["Global.Database.ResourceGroup.Name"]
$serverName = $OctopusParameters["Project.Database.Server"]
$databaseNameTemplate = "*-" + $OctopusParameters["Global.Database.Template"]

$azureDatabaseList = Get-AzureRmSqlDatabase -ResourceGroupName $resourceGroupName -ServerName $serverName

foreach ($azureDatabase in $azureDatabaseList)
{
	$databaseName = $azureDatabase.DatabaseName
    Write-Host "Checking to see if $databaseName matches the template $databaseNameTemplate"
	if ($databaseName -like $databaseNameTemplate)
    {    	
    	Write-Highlight "Deleting the database $databaseName because it matches the template"
		Remove-AzureRMSqlDatabase -ResourceGroupName $resourceGroupName -ServerName $serverName -DatabaseName $databaseName		
    }
}