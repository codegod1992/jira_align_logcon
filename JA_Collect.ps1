# TODO -  put a check in here around Admin perms. IIS config export will fail otherwise. Its in the deploy script so steal it
# if not admin, Write-Host("Please run this as Admin")

# vars we need
$date = Get-Date -Format "yyyy_MM_dd-HHmm"
$dirname = "AlignSupport_$date"
$zipname = "AlignSupport_$date.zip"

# Check if C:\temp exists and if not, create it
if(
Test-Path -PathType Container C:\temp)
{
Write-Host("C:\temp exists")
}
else
{
Write-Host("C:\temp doesn't exist, creating")
mkdir C:\temp
}

# Make temp Dir in AlignSupport and call it AlignSupport_date/timestamp
mkdir -Path C:\temp -Name $dirname

# Grab IIS config (this only works on MS Server 2016 +), putting it in a try which should also cover non-admin rights. Will this work???
try {Export-IISConfiguration -PhysicalPath C:\temp\$dirname -DontExportKeys -Force}
catch {Add-Content -Path C:\temp\$dirname\ISS_Error.txt "unable to read IIS config"}


# Grab ASP logs
Copy-Item -Path C:\log -Destination C:\temp\$dirname -Recurse

# Connetor logs? Pretty sure Bill just lumps these in C:\log so we can grab them with ASP logs, just pull the dir


# dotnet info to file
New-Item -Path C:\temp\$dirname\dotnet-info.txt -ItemType File
dotnet --info > C:\temp\$dirname\dotnet-info.txt

# TODO - host stats etc we should put into a single diag file. include with dotnet info??

# Sysinfo 
# This is overkill but maybe we can select certain fields we need (see Confluence page about what we need here)
Get-ComputerInfo -Property OsName, OsVersion, CsProcessors, CsNumberOfProcessors, CsNumberOfLogicalProcessors,  CsPhyicallyInstalledMemory, Os*Memory, OsLocale, TimeZone > C:\temp\$dirname\sysinfo.txt

# zip it all up and leave in C:/temp
Get-ChildItem -Path C:\temp\$dirname |  Compress-Archive -DestinationPath C:\temp\$zipname
Remove-Item -Path C:\temp\$dirname -Recurse
Write-Host("C:\temp\$zipname created")