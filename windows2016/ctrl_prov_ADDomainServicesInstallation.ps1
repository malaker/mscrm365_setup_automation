#Installing Active directory and promoting to DC
Enable-WSManCredSSP -Role Client -DelegateComputer * -Force
Enable-WSManCredSSP -Role Server -Force
Write-Host "CredSPP Enabled"
$allowed = @('WSMAN/*')
Write-Host "Enabling CredentialsDelegation policy group"
$key = 'hklm:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation'
if (!(Test-Path $key)) {
    md $key
}
New-ItemProperty -Path $key -Name AllowFreshCredentials -Value 1 -PropertyType Dword -Force            

$key = Join-Path $key 'AllowFreshCredentials'
if (!(Test-Path $key)) {
    md $key
}
$i = 1
$allowed |% {
    # Script does not take into account existing entries in this key
    New-ItemProperty -Path $key -Name $i -Value $_ -PropertyType String -Force
    $i++
}

$key = 'hklm:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation'

New-ItemProperty -Path $key -Name AllowFreshCredentialsWhenNTLMOnly -Value 1 -PropertyType Dword -Force            

$key = Join-Path $key 'AllowFreshCredentialsWhenNTLMOnly'
if (!(Test-Path $key)) {
    md $key
}
$i = 1
$allowed |% {
    # Script does not take into account existing entries in this key
    New-ItemProperty -Path $key -Name $i -Value $_ -PropertyType String -Force
    $i++
}

#Set-Item -Path "wsman:\localhost\service\auth\credSSP" -Value $True -Force
#New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation -Name AllowFreshCredentialsWhenNTLMOnly -Force
#New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly -Name 1 -Value "wsman\*" -PropertyType String

Write-Host "Enabled CredentialsDelegation policy group"
Write-Host "Controller ready"
Write-Host "Setting up timezome"
Set-TimeZone -Id "Mountain Standard Time"
Write-Host "Installing AD-Domain-Services"
install-windowsfeature AD-Domain-Services -IncludeManagementTools -Verbose
$pasw = (ConvertTo-SecureString "Vagrant1!" -AsPlainText -Force)
Write-Host "Importing ADDSDeployment"
Import-Module ADDSDeployment
Write-Host "Installing ADDSForest"
Install-ADDSForest -DomainName "sixteen.contoso.ad" -NoRebootOnCompletion -InstallDns:$true -Force -SafeModeAdministratorPassword $pasw
Write-Host "ADDSForest installtion finished"

#Exdending usage period. Here you can activate your own windows 2016 if you have license. Check slmgr command options
slmgr /rearm

Exit 0
