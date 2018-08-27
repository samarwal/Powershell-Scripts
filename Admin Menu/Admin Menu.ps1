Get-Module VMware.VimAutomation.Core

#connect to vcenter
Write-Host "Connecting to vCenter - $vcenter ...." -nonewline
$vcenter = "vcsatest.soo.algoma.com"
$user = "administrator@vsphere.local"
$pwd = "Algom@VCO1"
$success = Connect-VIServer $vcenter -User $user -Password $pwd
if ($success) { Write-Host "Connected!" -Foregroundcolor Green }
else {

    Write-Host "Try Connecting Again, aborting script" -Foregroundcolor Red
    exit
}
Write-Host ""

function Show-Menu {
    param (
        $Title = 'Admin Menu'
    )
    cls
    Write-Host "=========$Title========"

    Write-Host "1: Press '1' to change the cpu "
    Write-Host "2: Press '2' to change the memory"
    Write-Host "3: Press '3' to change diskspace on a number of disks"
    Write-Host "4: Press '4' to assign network information"
    Write-Host "Q: Press 'Q' to quit."
}

do {
    Show-Menu
    $input = Read-Host "Please make a selection"
    switch ($input) {
        '1' {
            cls
            'You chose option #3'
        }
        '2' {
            $inputVM = Read-Host "Name of VM to which you want to change your memory to?"
            $success = Get-VM -Name $inputVM
            if ($success) { Get-Vm -Name $inputVM }
            else {

                Write-Host "VM name does not exist, please try again!"
                $inputVM = Read-Host "Name of VM to which you want to change your memory to?"
                Get-VM -Name $inputVM
            }
            $inputMem = Read-Host "How much memory do you want?"
            Get-VM -Name $inputVM | Set-VM -MemoryGB $inputMem
            Write-Host "VM needs to be restarted in order for changes to appear"
            Write-Host "Restarting VM....."
            Restart-VM  $inputVM -Confirm:$false
            Write-Host "Giving 1 Min for VM to restart"
            Sleep 60
            Get-VM -Name $inputVM
        }
        '3' {
            cls
            'You chose option #3'
        }
        '4' {
            cls
            'You chose option #4'
        }'q' {
            return
        }
    }
    Pause
}
until ($input - 'q')



