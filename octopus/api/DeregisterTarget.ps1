$OctopusURL = $OctopusParameters["Global.Base.Url"]
$APIKey = $OctopusParameters["Global.Api.Key"]
$SpaceId = $OctopusParameters["Octopus.Space.Id"]
$template = "*-" + $OctopusParameters["Global.Application.Name.Template"]

$header = @{ "X-Octopus-ApiKey" = $APIKey }

Write-Host "Get a list of all machine policies"
$targetList = (Invoke-RestMethod "$OctopusUrl/api/$SpaceId/machines?skip=0&take=1000" -Headers $header)

foreach($target in $targetList.Items)
{
    if ($target.Name -like $template)
    {
        $targetId = $target.Id
        Write-Highlight "Deleting the target $targetId because the name matches the template"
        $deleteResponse = (Invoke-RestMethod "$OctopusUrl/api/$SpaceId/machines/$targetId" -Headers $header -Method Delete)

        Write-Host "Delete Response $deleteResponse"
    }
}