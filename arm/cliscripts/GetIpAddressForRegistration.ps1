$ResourceGroup = $OctopusParameters["Project.ResourceGroup.Name"]
$VmName = $OctopusParameters["Project.VM.Name"]
$ipName = $VmName + "Ip"

$IPAddress = Get-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroup -Name $ipName
$IPAddress = $IPAddress.IpAddress

Write-Host "The IP Address is $IPAddress"

Set-OctopusVariable -name "IPAddress" -value $IPAddress