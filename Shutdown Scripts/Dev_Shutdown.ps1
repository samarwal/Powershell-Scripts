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




#Get All the VM's across all the platforms
Write-Host "**** List of all the VM's *******************************"
Get-VM | Select Name, PowerState, VMHost

Write-Host ""
Write-Host "**** List of all the VM's with tags *********************"
Get-TagAssignment | Select Tag, Entity


#Get all the VM's that are powered on
Write-Host ""
Write-Host "**** List of all the VM's that are powered ON ***********"
Get-VM | where-object {$_.PowerState -eq "PoweredOn" }
$PoweredOnVm = Get-VM | where-object {$_.PowerState -eq "PoweredOn" }


#Get all the development VM's
Write-Host ""
Write-Host "**** List of all the Development VM's *******************"
Get-VM -Tag Development
$DevVM = Get-VM -Tag Development



#ShutDown the Development VM's
foreach  ( $PoweredOnVm in $DevVM) {
    $vminfo = get-view -Id $PoweredOnVm.ID

    if ($vminfo.Runtime.PowerState -ne "PoweredOff") {
        if ($vminfo.config.Tools.ToolsVersion -eq 0) {

            Write-Host "No VMware tools detected in $PoweredOnVm , hard power this one" -ForegroundColor Yellow
            Stop-VM $PoweredOnVm -confirm:$false
        }
        else {
            write-host "VMware tools detected.  I will attempt to gracefully shutdown $PoweredOnVm"
            $vmshutdown = $PoweredOnVm | shutdown-VMGuest -Confirm:$false
        }
    }
}

#Lets wait a minute or so for shutdowns to complete
Write-Host ""
Write-Host "Giving VMs 1 minute to completely shut down"
Write-Host ""
Sleep 60

#Check whether the Dev VM's are still on, if they are then shut them down
foreach  ( $PoweredOnVm in $DevVM) {
    $vminfo = get-view -Id $PoweredOnVm.ID

    if ($vminfo.Runtime.PowerState -ne "PoweredOff") {
        if ($vminfo.config.Tools.ToolsVersion -eq 0) {

            Write-Host "No VMware tools detected in $PoweredOnVm , hard power this one" -ForegroundColor Yellow
            Stop-VM $PoweredOnVm -confirm:$false
        }
        else {
            write-host "VMware tools detected.  I will attempt to gracefully shutdown $PoweredOnVm"
            $vmshutdown = $PoweredOnVm | shutdown-VMGuest -Confirm:$false
        }
    }
}

#To generate csv file
$powerstate = @()
foreach ($PoweredOnVm in $DevVM) {
    $vm = Get-VM -Name $PoweredOnVm

    $powerstate += (Get-VM $vm |

        Select Name, PowerState,

        @{N = 'VMHost'; E = {$_.VMHost.name}})

}

$CurrentDate = Get-Date
$Currentdate = $Currentdate.ToString('MM-dd-yyyy')
$powerstate | Export-Csv -Path C:\temp\Devpowerstate_report_$CurrentDate.csv -NoTypeInformation -UseCulture

$file = "C:\temp\Devpowerstate_report_$CurrentDate.csv"
$smtpServer = "webmail.algoma.com"
$att = New-Object Net.mail.Attachment($file)
$msg = New-Object net.Mail.Mailmessage
$smtp = new-object Net.Mail.SmtpClient($smtpServer)


#Send out an email with the names
$msg.From = "agarwalsamarth06@gmail.com"
$msg.To.Add("samarth.agarwal@algoma.com")
$msg.Subject = "Notification for the Development Servers Shutdown"
$msg.Body = "Attached is the Development shutdown report "
$msg.Attachments.Add($att)
$smtp.Send($msg)
$att.Dispose()

#Disconnect vcenter server
disconnect-viserver $vcenter -Confirm:$false












