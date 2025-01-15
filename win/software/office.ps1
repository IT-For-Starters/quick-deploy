
#### Changable Variables!
$scriptLocation = "C:\temp\quick-deploy\software\office-365"

$installerUrl = "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_18129-20158.exe";
$installerName = "odt.exe";

$installerArguments = "/quiet /norestart";
$installMSI = $true;

$configName = "odt.xml";
$configUrl = "";


#### Step 0 - Init session
$timestamp = Get-Date -Format "yyyy-MM-dd HH-mm"
Start-Transcript -Path "$scriptLocation\LOG_$timestamp.txt"


#### Step 1 - Download Installer
$installerDir = "$scriptLocation\files";
$installerPath = "$installerDir\$installerName"

Write-Host "[DL] Checking if installer Directory Exists"
if (!(Test-Path -Path "$installerDir" -PathType Container)) {
    Write-Host "[DL] No - creating..."
    New-Item -Path "$installerDir" -ItemType Directory | Out-Null
} else {
    Write-Host "[DL] Yes - proceeding..."
}

Write-Host "[DL] Checking if installer exists already"
if (!(Test-Path -Path "$installerPath" -PathType Leaf)) {
    Write-Host "[DL] No - downloading..."
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($installerUrl, $installerPath)
} else {
    Write-Host "[DL] Yes - proceeding..."
}

#### Step 1.1 - Download Config
$configPath = "$installerDir\$configName"

Write-Host "[DL] Checking if installer Directory Exists"
if (!(Test-Path -Path "$installerDir" -PathType Container)) {
    Write-Host "[DL] No - creating..."
    New-Item -Path "$installerDir" -ItemType Directory | Out-Null
} else {
    Write-Host "[DL] Yes - proceeding..."
}

Write-Host "[CONF] Checking if config exists already"
if (!(Test-Path -Path "$configPath" -PathType Leaf)) {
    Write-Host "[CONF] No - downloading..."
    $webClient1 = New-Object System.Net.WebClient
    $webClient1.DownloadFile($configUrl, $configPath)
} else {
    Write-Host "[CONF] Yes - proceeding..."
}


#### Step 2 - Run Installer
Write-Host "[INS] Running Installer"
if ($installMSI) {
    $installArgs = "/i $installerPath $installerArguments"
    $installProcess = Start-Process -FilePath "msiexec.exe" -ArgumentList $installArgs -Wait -PassThru
} else {
    $installProcess = Start-Process -FilePath "$installerPath" -ArgumentList $installerArguments -Wait -PassThru
}
$exitcode = $installProcess.ExitCode
Write-Host "[INS] Software Installation Exit Code is $exitcode"
if ($installProcess.ExitCode -eq 0) {
    # Installation was successful
    Write-Host "[INS] Installation Completed"
    Remove-Item "$installerPath" -Confirm:$false
}
else {
    # Installation failed
    Write-Error "[INS] Installation Failed"
    Remove-Item "$installerPath" -Confirm:$false
    Stop-Transcript
    exit 1
}

Stop-Transcript
exit 0