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

#Import vm name and ip from csv file
$CurrentDate = Get-Date
$Currentdate = $Currentdate.ToString('MM-dd-yyyy')
Import-Csv -Path C:\temp\Devpowerstate_report_$CurrentDate.csv |

foreach {
    $strNewVMName = $_.name

    #Generate a view for each vm to determine power state  
    $vm = Get-View -ViewType VirtualMachine -Filter @{"Name" = $strNewVMName}
    if ($vm.Runtime.PowerState -ne "PoweredOn") {

        Write-Host "Powering On $strNewVMName ----"
        Get-VM $strNewVMName | Start-VM
        Sleep 60

    }
}

#To generate csv file
$PoweredOnVm = $PoweredOnVm = Get-VM | where-object {$_.PowerState -eq "PoweredOn" }
$DevVM = Get-VM -Tag Development
$powerstate = @()
foreach ($PoweredOnVm in $DevVM) {
    $vm = Get-VM -Name $PoweredOnVm

    $powerstate += (Get-VM $vm |

        Select Name, PowerState,

        @{N = 'VMHost'; E = {$_.VMHost.name}})

}

$powerstate | Export-Csv -Path C:\temp\Devpowerstate_report_$CurrentDate.csv -NoTypeInformation -UseCulture

$file = "C:\temp\Devpowerstate_report_$CurrentDate.csv"
$smtpServer = "webmail.algoma.com"
$att = New-Object Net.mail.Attachment($file)
$msg = New-Object net.Mail.Mailmessage
$smtp = new-object Net.Mail.SmtpClient($smtpServer)


#Send out an email with the names
$msg.From = "agarwalsamarth06@gmail.com"
$msg.To.Add("samarth.agarwal@algoma.com")
$msg.Subject = "Notification for the Development Servers PowerOn"
$msg.Body = "Attached is the Development powerOn report "
$msg.Attachments.Add($att)
$smtp.Send($msg)
$att.Dispose()

#Disconnect vcenter server
disconnect-viserver $vcenter -Confirm:$false

