if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
#Adding kb and vagrant users to proper AD groups
#Enabling CredSPP 
Set-ExecutionPolicy Bypass -Scope Process

while ($true) {
    try {
        Get-ADDomain | Out-Null
        break
    } catch {
        Start-Sleep -Seconds 10
    }
}


$adDomain = Get-ADDomain
$domain = $adDomain.DNSRoot
$domainDn = $adDomain.DistinguishedName
$usersAdPath = "CN=Users,$domainDn"
$password = ConvertTo-SecureString -AsPlainText 'zaq1@WSX' -Force
$name = 'kb'
$vagrant = "vagrant"

New-ADUser `
    -Path $usersAdPath `
    -Name $name `
    -UserPrincipalName "$name@$domain" `
    -EmailAddress "$name@$domain" `
    -GivenName 'kb' `
    -Surname 'Doe' `
    -DisplayName 'kb' `
    -AccountPassword $password `
    -Enabled $true `
    -PasswordNeverExpires $true
# add user to the Domain Admins group.
Add-ADGroupMember `
    -Identity 'Domain Admins' `
    -Members "CN=$name,$usersAdPath"
Add-ADGroupMember `
    -Identity 'Administrators' `
    -Members "CN=$name,$usersAdPath"


Add-ADGroupMember `
    -Identity 'Performance Monitor Users' `
    -Members "CN=$vagrant,$usersAdPath"
Add-ADGroupMember `
    -Identity 'Performance Log Users' `
    -Members "CN=$vagrant,$usersAdPath"

Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ResetServerAddresses
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False
Write-Host "Enabling CredSPP"


Exit 0
