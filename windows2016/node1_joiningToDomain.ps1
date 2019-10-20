Enable-WSManCredSSP -Role Client -DelegateComputer * -Force
Enable-WSManCredSSP -Role Server -Force

$allowed = @('WSMAN/*')

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


Write-Host "Setting up timezome"
Set-TimeZone -Id "Mountain Standard Time"

$dnsAddress = "192.168.50.4"
Write-Debug "Setting DNS"
Set-DnsClientServerAddress -InterfaceAlias "Ethernet 2" -ServerAddresses $dnsaddress
Write-Debug "Creating AD admin credentials"
$secpasswd = ConvertTo-SecureString "vagrant" -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ("vagrant@sixteen", $secpasswd)
Write-Debug "Adding computer to domain..."

Add-Computer -DomainName "sixteen.contoso.ad" -Credential $mycreds
Write-Debug "Adding computer to domain finished"
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False

