if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

# Your script here
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco feature enable -n=allowGlobalConfirmation

New-Item C:\office\ -ItemType Directory
Copy-Item C:\vagrant\*.iso C:\office\

Copy-Item C:\vagrant\*.ini C:\office\ 
Mount-DiskImage -ImagePath C:\office\sql.iso

Write-Host "Images mounted"
& C:\vagrant\sqlInstallation.ps1

choco install sql-server-management-studio

choco install sql2016-clrtypes

choco install sql2016-smo --ignore-checksums


Exit 0