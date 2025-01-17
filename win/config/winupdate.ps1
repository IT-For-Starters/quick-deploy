
#### Changable Variables!
$scriptLocation = "C:\temp\quick-deploy\config\windows-update"

#### Step 0 - Init session
$timestamp = Get-Date -Format "yyyy-MM-dd HH-mm"
Start-Transcript -Path "$scriptLocation\LOG_$timestamp.txt"

Install-Module -Name PSWindowsUpdate -Force -SkipPublisherCheck
Import-Module PSWindowsUpdate
Get-WindowsUpdate | Install-WindowsUpdate -AcceptAll -AutoReboot

Stop-Transcript
exit 0