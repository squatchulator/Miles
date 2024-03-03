function 480Banner()
{
    $banner=@"
    _  _    ___   ___              _   _ _     
   | || |  ( _ ) / _ \       _   _| |_(_) |___ 
   | || |_ / _ \| | | |_____| | | | __| | / __|
   |__   _| (_) | |_| |_____| |_| | |_| | \__ \
      |_|  \___/ \___/       \__,_|\__|_|_|___/
   
         __    EEEK!
         /  \   ~~|~~
        (|00|)    |
         (==)  --/
       ___||___
      / _ .. _ \
     //  |  |  \\
    //   |  |   \\
    ||  / /\ \  ||
   _|| _| || |_ ||_  
   \|||___||___|||/
   
"@
       Write-Host $banner
}

function 480Connect([string] $server)
{
    $conn = $global:DefaultVIServer
    if ($conn){
        $msg = "Already connected to {0}!" -f $conn
        Write-Host -ForegroundColor Green $msg
    } else {
        $conn = Connect-VIServer -Server $server
    }
}

function Get-480Config([string] $config_path)
{
    Write-Host "Reading " $config_path
    $conf=$null
    if (Test-Path $config_path)
    {
        $conf = (Get-Content -Raw -Path $config_path | ConvertFrom-Json)
        $msg = "Using Configuration at {0}" -f $config_path
        Write-Host -ForegroundColor "Green" $msg
    } else 
    {
        Write-Host -ForegroundColor "Yellow" "No Configuration"
    }
    return $conf
    
}

function Select-VM([string] $folder)
{
    $selected_vm=$null
    try {
        $vms = Get-VM -Location $folder
        $index = 1
        foreach($vm in $vms)
        {
            Write-Host [$index] $vm.name
            $index+=1
        }
        $pick_index = Read-Host "Which index number [x] do you wish to pick?"
        $selected_vm = $vms[$pick_index -1]
        Write-Host "You picked " $selected_vm.name
        return $selected_vm
        # Add something to validate selections i.e. can't pick VM 123123
    }
    catch {
        Write-Host "Invalid folder: $folder" -ForegroundColor "Red"
    }
}

function New-LinkedClone {
    param(
        [string] $target,
        [string] $newname
    )
  
    $config = Get-480Config "/home/miles/Desktop/480/480.json"

    Connect-VIServer -Server $config.vcenter_server
    $vm = Get-VM -Name $target
    $snapshot = Get-Snapshot -VM $vm -Name "Base"
    $vmhost = Get-VMHost -Name $config.ip
    $ds = Get-Datastore -Name $config.dsname
    $linkedclone = "{0}.linked" -f $vm.name
    $linkedvm = New-VM -LinkedClone -Name $linkedclone -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds
    $newvm = New-VM -Name $newname -VM $linkedvm -VMHost $vmhost -Datastore $ds -Location $config.vm_folder
    $newvm | New-Snapshot -Name "Base"
    $linkedvm | Remove-VM -Confirm:$false
    $newvm | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $config.adapter
    Write-Host "Done."
}