#Installs SQL Server locally with standard settings for Developers/Testers.
# Install SQL from command line help - https://msdn.microsoft.com/en-us/library/ms144259.aspx
$sw = [Diagnostics.Stopwatch]::StartNew()
$currentUserName = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name;
$SqlServerIsoImagePath = "C:\office\sql.iso"

#Mount the installation media, and change to the mounted Drive.
$mountVolume = Mount-DiskImage -ImagePath $SqlServerIsoImagePath -PassThru
$driveLetter = ($mountVolume | Get-Volume).DriveLetter
$drivePath = $driveLetter + ":"
push-location -path "$drivePath"

#Install SQL Server locally with our default settings. 
# Only the Sql Engine and LocalDB
# i.e. no Replication, FullText, Data Quality, PolyBase, R, AnalysisServices, Reporting Services, Integration service, Master Data Services, Books Online(BOL) or SDK are installed.
.\Setup.exe  /q  /CONFIGURATIONFILE=C:\office\ConfigurationFile2016.ini /IACCEPTSQLSERVERLICENSETERMS=true
#Dismount the installation media.
pop-location
Dismount-DiskImage -ImagePath $SqlServerIsoImagePath

#print Time taken to execute
$sw.Stop()
"Sql install script completed in {0:c}" -f $sw.Elapsed;