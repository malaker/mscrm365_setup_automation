if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

Import-Module activedirectory
$duser = Get-ADUser -Identity kb
Add-LocalGroupMember -Group "Performance Monitor Users" -Member $duser.SID.value
Add-LocalGroupMember -Group "Performance Log Users" -Member $duser.SID.value


$duser = Get-ADUser -Identity vagrant
Add-LocalGroupMember -Group "Performance Monitor Users" -Member $duser.SID.value
Add-LocalGroupMember -Group "Performance Log Users" -Member $duser.SID.value

Remove-Item -Path C:\Logs\logcrm.txt -Force -ErrorAction Ignore
Copy-Item C:\vagrant\crmconfig.xml  c:\crmsetup\

$pw = ConvertTo-SecureString "zaq1@WSX" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList "sixteen\kb",$pw

Start-Sleep -Seconds 5
$path = "C:\vagrant\CrmInstall.ps1"
$s1 = new-pssession -ComputerName vagrant-2016.sixteen.contoso.ad -Credential $cred #-Authentication Credssp
try { 


Invoke-Command -Session $s1 -ScriptBlock {

$pw2 = ConvertTo-SecureString "zaq1@WSX" -AsPlainText -Force
$cred2 = New-Object System.Management.Automation.PSCredential -ArgumentList "sixteen\kb",$pw2
$s2 = new-pssession -ComputerName node1.sixteen.contoso.ad -Credential $cred2 -Authentication Credssp
Invoke-Command -Session $s2 -ScriptBlock {

    function Wait-ForFinish($time){
        $initialtime = $time
        while($true){
            if ($time -gt 9700){
                break;
            }
            
            Start-Sleep -Seconds $initialtime
            
            $installationCompletionMatch = Select-String -Path C:\Logs\logcrm.txt -Pattern "The installation of Dynamics 365 Server has been successfully completed"
           
            if($installationCompletionMatch.Length -lt 1){
            
            
                $time=$time+60;
                Write-Host "Waiting for completion remote $time";
                Get-Content -Path C:\Logs\logcrm.txt -Tail 10 -Force
            
            }ElseIF(installationCompletionMatch -gt 0){
                Write-Host "CRM installation completed";
                break;
            }else{
                Write-Host "CRM installation failed";
            }
        }
    }
        Write-Host "Installation started"
        Start-Process -Wait -FilePath C:\crmsetup\SetupServer.exe "/Q /config c:\crmsetup\crmconfig.xml /L C:\logs\logcrm.txt /InstallAlways"

        Wait-ForFinish 5

    }
}
}catch { 
    $_
    write-host "found error" 
    write-host $error[0] 
}

Exit 0

