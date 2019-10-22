#extracting files from crm server exe
$crmExists = test-path C:\vagrant\CRM9.0-Server-ENU-amd64.exe
$output = "C:\vagrant\CRM9.0-Server-ENU-amd64.exe"
$url = "https://download.microsoft.com/download/B/D/0/BD0FA814-9885-422A-BA0E-54CBB98C8A33/CRM9.0-Server-ENU-amd64.exe"
if($crmExists -eq $false){
Import-Module BitsTransfer
Start-BitsTransfer -Source $url -Destination $output
}

New-Item -ItemType directory -Path C:\crmsetup -Force
& C:\vagrant\CRM9.0-Server-ENU-amd64.exe /quiet /extract:C:\crmsetup\ /log:C:\logs\log1.txt

Copy-Item C:\vagrant\crmconfig.xml C:\crmsetup\

$contentReady = $false
while ($contentReady -eq $false){

    $itemsCount = ( Get-ChildItem C:\crmsetup  ).Count;

    if ($itemsCount -gt 0){
        $contentReady = $true
    }
}
$contentReady = $false
while($contentReady -eq $false){
    $matches = Select-String -Path C:\Logs\log1.txt -Pattern "Done extracting the files"
    
    if ( $matches.Length -gt 0 ){
        $contentReady = $true
    }else{
        Write-Host "Waiting for files extraction completion"
    }
    Write-Host $matches
    Start-Sleep -Seconds 1
}
Write-Host "All files extracted - ready for crm installation"

Exit 0