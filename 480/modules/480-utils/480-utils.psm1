function 480Banner() {
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

function 480Connect([string] $server) {
    Write-Host "Server value received: $server"
    $conn = $global:DefaultVIServer
    if ($conn) {
        $msg = "Already connected to {0}!" -f $conn
        Write-Host -ForegroundColor Green $msg
    } else {
        $conn = Connect-VIServer -Server $server
    }
}

function Get-480Config([string] $config_path) {
    Write-Host "Reading " $config_path
    $conf=$null
    if (Test-Path $config_path) {
        $conf = (Get-Content -Raw -Path $config_path | ConvertFrom-Json)
        $msg = "Using Configuration at {0}" -f $config_path
        Write-Host -ForegroundColor "Green" $msg
    } else {
        Write-Host -ForegroundColor "Yellow" "No Configuration"
    }
    return $conf
}

function Select-VM([string] $folder) {
    $selected_vm=$null
    try {
        $vms = Get-VM -Location $folder
        if ($vms.Count -eq 0) {
            Write-Host "No VMs found in folder '$folder'" -ForegroundColor Yellow
            return $null
        }
        $index = 1
        foreach($vm in $vms) {
            Write-Host "[$index] $($vm.Name)"
            $index+=1
        }
        $pick_index = Read-Host "Which index number [x] do you wish to pick?"
        $selected_vm = $vms[$pick_index - 1]
        Write-Host "You picked $($selected_vm.Name)"
        return $selected_vm
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
        return $null
    }
}

function New-LinkedClone {
    param(
        [string] $target,
        [string] $newname
    )

    $config = Get-480Config "/home/miles/Desktop/480/480.json"
    try {
        Connect-VIServer -Server $config.vcenter_server -ErrorAction Stop

        $vm = Get-VM -Name $target -ErrorAction Stop
        $snapshot = Get-Snapshot -VM $vm -Name "Base" -ErrorAction Stop
        $vmhost = Get-VMHost -Name $config.ip -ErrorAction Stop
        $ds = Get-Datastore -Name $config.dsname -ErrorAction Stop

        $linkedclone = "{0}.linked" -f $vm.Name
        $linkedvm = New-VM -LinkedClone -Name $linkedclone -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds -ErrorAction Stop
        $newvm = New-VM -Name $newname -VM $linkedvm -VMHost $vmhost -Datastore $ds -Location $config.vm_folder -ErrorAction Stop
        $newvm | New-Snapshot -Name "Base" -ErrorAction Stop
        $linkedvm | Remove-VM -Confirm:$false -ErrorAction Stop

        $networkAdapters = $newvm | Get-NetworkAdapter -ErrorAction Stop

        foreach ($adapter in $networkAdapters) {
            Write-Host "Configuring network adapter $($adapter.Name)"
            $networks = Get-VirtualNetwork
            Write-Host "Available Networks for adapter $($adapter.Name):"
            $index = 1
            foreach ($network in $networks) {
                Write-Host "[$index] $($network.Name)"
                $index++
            }

            $networkIndex = Read-Host "Select the network index to assign to the adapter $($adapter.Name)"
            $selectedNetwork = $networks[$networkIndex - 1]

            $adapter | Set-NetworkAdapter -NetworkName $selectedNetwork.Name -Confirm:$false -ErrorAction Stop
        }

        Write-Host "Linked clone created successfully."
    }
    catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
    finally {
        Disconnect-VIServer -Confirm:$false -ErrorAction SilentlyContinue
    }
}


function New-Network {
    param(
        [string] $newswitch,
        [string] $newportgroup
    )
    $config = Get-480Config "/home/miles/Desktop/480/480.json"
    Connect-VIServer -Server $config.vcenter_server
    $vmhost = Get-VMHost -Name $config.ip

    New-VirtualSwitch -VMHost $vmhost -Name $newswitch
    $switch = Get-VirtualSwitch -VMHost $vmhost -Name $newswitch
    New-VirtualPortGroup -VirtualSwitch $switch -Name $newportgroup
    $portgroupInfo = Get-VirtualPortGroup -VirtualSwitch $switch -Name $newportgroup

    if ($switch -and $portgroupInfo) {
        Write-Host "New virtual switch created:"
        $switch | Format-Table -AutoSize
        Write-Host "New port group created on virtual switch $newswitch"
        $portgroupInfo | Format-Table -AutoSize
    } else {
        Write-Host "Error: Failed to get information about the created network."
    }
}

function Switch-Network {
    param (
        [string] $vmName
    )

    $config = Get-480Config "/home/miles/Desktop/480/480.json"
    Connect-VIServer -Server $config.vcenter_server

    $vm = Get-VM -Name $vmName

    if ($vm) {
        $networkAdapters = $vm | Get-NetworkAdapter

        if ($networkAdapters) {
            Write-Host "Available Network Adapters for VM $vmName"
            $index = 1
            foreach ($adapter in $networkAdapters) {
                Write-Host "[$index] $($adapter.Name)"
                $index++
            }

            $adapterIndex = Read-Host "Select the network adapter index to modify"
            $selectedAdapter = $networkAdapters[$adapterIndex - 1]

            $networks = Get-VirtualNetwork
            Write-Host "Available Networks:"
            $index = 1
            foreach ($network in $networks) {
                Write-Host "[$index] $($network.Name)"
                $index++
            }

            $networkIndex = Read-Host "Select the network index to assign to the adapter"
            $selectedNetwork = $networks[$networkIndex - 1]

            $selectedAdapter | Set-NetworkAdapter -NetworkName $selectedNetwork.Name -Confirm:$false
            Write-Host "Network adapter updated successfully."
        } else {
            Write-Host "Error: No network adapters found for VM $vmName." -ForegroundColor Red
        }
    } else {
        Write-Host "Error: VM $vmName not found." -ForegroundColor Red
    }
}

function Get-IP {
    param(
        [string] $vmName
    )

    $config = Get-480Config "/home/miles/Desktop/480/480.json"
    Connect-VIServer -Server $config.vcenter_server

    $vms = Get-VM -Name $vmName

    foreach ($vm in $vms) {
        $networkAdapter = $vm | Get-NetworkAdapter | Select-Object -First 1

        if ($networkAdapter) {
            $macAddress = $networkAdapter.MacAddress
            $ipAddress = $vm.guest.ipAddress[0] 

            [PSCustomObject]@{
                VMName = $vm.Name
                IPAddress = $ipAddress
                MACAddress = $macAddress
            }
        } else {
            Write-Host "Error: No network adapter found for VM $($vm.Name)" -ForegroundColor Red
        }
    }
}

function Show-Menu {
    param (
        [string] $folder,
        [string] $selectedVM
    )

    Write-Host "Selected VM: $selectedVM"
    Write-Host "[1] Create Linked Clone"
    Write-Host "[2] Power On VM"
    Write-Host "[3] Power Off VM"
    Write-Host "[4] Change Network"
    Write-Host "[5] New Network"
    Write-Host "[6] Get Network Info"
    Write-Host "[7] Exit"

    $choice = Read-Host "Enter your choice by index number [x]"

    switch ($choice) {
        1 {
            New-LinkedClone -target $selectedVM -newname "NewClone_$selectedVM"
        }
        2 {
            Start-VM -VM $selectedVM
        }
        3 {
            Stop-VM -VM $selectedVM
        }
        4 {
            Switch-Network -vmName $selectedVM
        }
        5 {
            $newswitch = Read-Host "Enter the name of the new switch"
            $newportgroup = Read-Host "Enter the name of the new port group"
            New-Network -newswitch $newswitch -newportgroup $newportgroup
        }
        6 {
            Get-IP -vmName $selectedVM
        }
        7 { exit }
        default { Write-Host "Invalid choice" }
    }
}

function Main {
    Clear-Host
    480Banner
    $config = Get-480Config "/home/miles/Desktop/480/480.json"
    480Connect
    if (-not $config) {
        Write-Host "Error: Configuration not found" -ForegroundColor Red
        return
    }

    $folderChoice = Read-Host "Choose folder (BASE or PROD)"
    $folder = if ($folderChoice.ToLower() -eq "base") { $config.base_folder } elseif ($folderChoice.ToLower() -eq "prod") { $config.prod_folder } else { Write-Host "Invalid folder choice"; return }

    $vms = Get-VM -Location $folder

    if ($vms) {
        Write-Host "Available VMs in folder '$folder':"
        $selectedVM = Select-VM $folder
        Show-Menu -folder $folder -selectedVM $selectedVM.Name
    } else {
        Write-Host "No VMs found in folder '$folder'" -ForegroundColor Yellow
    }
}