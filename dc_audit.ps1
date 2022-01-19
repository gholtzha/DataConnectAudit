# Get Downloads path
$downloads = (New-Object -ComObject Shell.Application).NameSpace('shell:Downloads').Self.Path

# Delete output file if exists
if (Test-Path -Path "$downloads\actian_installed.txt") {
  Remove-Item "$downloads\actian_installed.txt"
}

# Set search path for registry of installed products
$paths=@(
  'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\',
  'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\'
)

# Get all installed products into temp file
foreach($path in $paths){
  Get-ChildItem -Path $path | 
    Get-ItemProperty | 
      Select-Object  DisplayName, DisplayVersion, Publisher , InstallDate | Format-Table –AutoSize |  Out-File -FilePath $downloads\actian_installed.txt
} 

# Filter on Actian related products
$filters = @("actian", "pervasive", "Publisher", "Integrator", "--")

# Filter out non-Actian roducts
Get-Content "$downloads\actian_installed.txt" | Select-String -pattern $filters | Out-File $downloads\actian_installeddo.txt

# Delete original output file
if (Test-Path -Path "$downloads\actian_installed.txt") {
  Remove-Item "$downloads\actian_installed.txt"
}

# Rename file with Actian products
if (Test-Path -Path "$downloads\actian_installeddo.txt") {
Rename-Item -Path "$downloads\actian_installeddo.txt" -NewName "$downloads\actian_installed.txt"
}

# Discover all drives on system
$Drives = Get-PSDrive -PSProvider 'FileSystem'

# Search of DataConnect artifacts n all drives
foreach($Drive in $drives) {
   Get-ChildItem -Path $Drive.Root -Include "djengine.exe", "cosmos.ini", "*.map.xml", "Cosmos9"   -Recurse -ErrorAction SilentlyContinue -Force | Out-File -FilePath "$downloads\actian_installed.txt" -Append
}
