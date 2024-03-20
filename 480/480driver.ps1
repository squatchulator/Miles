Import-Module '480-utils' -Force
#$conf = Get-480Config -config_path = "/home/miles/Desktop/Miles/480/480.json"
$conf = Get-480Config /home/miles/Desktop/480/480.json
480Connect -server $conf.vcenter_server
Main
<#
Select-VM -folder "BASEVM"
#>

