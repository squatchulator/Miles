Import-Module '480-utils' -Force
Main

<#
480Banner
$conf = Get-480Config -config_path = "/home/miles/Desktop/Miles/480/480.json"
480Connect -server $conf.vcenter_server
Select-VM -folder "BASEVM"
#>
