function Get-usbCounter {

    $usbDevCounter = @()

    gwmi win32_usbdevice | % {$usbDevCounter += 1}

    $activeUsbDevices = @($usbDevCounter).length

    return $activeUsbDevices

}

function Get-pnpId {

    $pnpId = @()

    gwmi win32_usbdevice | 
        select -exp PNPDeviceID | 
        sls 'PID_.*?(?<=)[A-Z,0-9]\\(.*?)$' -AllMatches | 
        % {
            $pnpId += $_.Matches.groups[1]
        }

    return $pnpId

}

Clear-Variable -Name promptExit

While ("n" -notcontains $promptExit) {

    $bPnpId = Get-pnpId

    $bDevices = Get-usbCounter

    Write "---------------------"

    Write-Host "Active USB devices: $bDevices" -ForegroundColor Yellow

    Start-sleep 2

    Write-host "Connect target USB device!" -ForegroundColor Yellow

    Start-sleep 2
    
    $checkDevice = Read-Host "Target USB device connected? (y/n)"

    while("y" -notcontains $checkDevice) {

        $checkDevice = Read-Host "Target USB devices connected? (y/n)"

    }

    $uDevices = Get-usbCounter

    if ($bDevices -eq $uDevices) {

        Write-Host "Device not connected! Please try again..." -ForegroundColor Red

    }

    elseif ($bDevices -gt $uDevices) {

        $status = 'Disconnected'
    
        Write-Host "Device disconnected!" -ForegroundColor Red

    }

    else { 

        $status = 'Connected'

    }

    $uPnpId = Get-pnpId

    Write-Host "Active USB devices: $uDevices" -ForegroundColor Green
    
    $c = (Compare-Object -ReferenceObject $bPnpId -DifferenceObject $uPnpId).InputObject.Value

    $i = 1

    foreach ($dev in $c) {

        Write-Host "$status PNP ID #$i : $dev" -ForegroundColor Green

        $i++

    }

    Write "---------------------"

    $promptExit = Read-Host "Continue? (y/n)"

}
