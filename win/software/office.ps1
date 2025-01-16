
#### Changable Variables!
$scriptLocation = "C:\temp\quick-deploy\software\office-365"

$installerUrl = "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_18129-20158.exe";
$installerName = "odt.exe";

$configName = "odt.xml";
$configUrl = "https://raw.githubusercontent.com/IT-For-Starters/quick-deploy/refs/heads/main/win/meta/Office_NewBuild_01.xml";


#### Step 0 - Init session
$timestamp = Get-Date -Format "yyyy-MM-dd HH-mm"
Start-Transcript -Path "$scriptLocation\LOG_$timestamp.txt"


#### Step 1 - Download Installer
$installerDir = "$scriptLocation\files";
$installerPath = "$installerDir\$installerName"
$installerTempPath = "$installerDir\temp"

Write-Host "[DL] Checking if installer Directory Exists"
if (!(Test-Path -Path "$installerDir" -PathType Container)) {
    Write-Host "[DL] No - creating..."
    New-Item -Path "$installerDir" -ItemType Directory | Out-Null
}
else {
    Write-Host "[DL] Yes - proceeding..."
}

Write-Host "[DL] Checking if installer Temp Directory Exists"
if (!(Test-Path -Path "$installerTempPath" -PathType Container)) {
    Write-Host "[DL] No - creating..."
    New-Item -Path "$installerTempPath" -ItemType Directory | Out-Null
}
else {
    Write-Host "[DL] Yes - proceeding..."
}

Write-Host "[DL] Checking if installer exists already"
if (!(Test-Path -Path "$installerPath" -PathType Leaf)) {
    Write-Host "[DL] No - downloading..."
    $installerUrl
    $installerPath
    try {
        Start-BitsTransfer -Source $installerUrl -Destination $installerPath
        #$webClient.DownloadFile($installerUrl, $installerPath)
    }
    catch {
        Write-Host "Error message: $($_.Exception.Message)"
        Write-Host "Stack trace: $($_.Exception.StackTrace)"
        Write-Host "Inner Exception: $($_.Exception.InnerException)"
    }
    
}
else {
    Write-Host "[DL] Yes - proceeding..."
}

#### Step 1.1 - Download Config
$configPath = "$installerDir\$configName"

Write-Host "[CONF] Checking if config exists already"
if (!(Test-Path -Path "$configPath" -PathType Leaf)) {
    Write-Host "[CONF] No - downloading..."
    Start-BitsTransfer -Source $configUrl -Destination $configPath
    #$webClient.DownloadFile($configUrl, $configPath)
}
else {
    Write-Host "[CONF] Yes - proceeding..."
}




#### Step 2 - Run Installer
Write-Host "[INS1] Running Installer to get ODT"
$installerArguments = "/extract:`"$installerTempPath`" /log:`"$installerTempPath\OfficeInstall.log`" /quiet /norestart"
try {
    $installProcess = Start-Process -FilePath "$installerPath" -ArgumentList $installerArguments -Wait -PassThru
}
catch {
    Write-Host "Error message: $($_.Exception.Message)"
    Write-Host "Stack trace: $($_.Exception.StackTrace)"
    Write-Host "Inner Exception: $($_.Exception.InnerException)"
}


$exitcode = $installProcess.ExitCode
Write-Host "[INS1] Software Installation Exit Code is $exitcode"
if ($installProcess.ExitCode -eq 0) {
    # Installation was successful
    Write-Host "[INS1] Installation Completed"
    
}
else {
    # Installation failed
    Write-Error "[INS1] Installation Failed"
    #Remove-Item -Path $installerDir -Recurse -Force -Confirm:$false
    Stop-Transcript

    exit 1
}

Set-Location "$installerTempPath"


#### Step 3 - Run Download
Write-Host "[INSDL] Running Installer to Download Software"
$installerArguments = "/download `"$configPath`""
$installProcess = Start-Process -FilePath "$installerTempPath\setup.exe" -ArgumentList $installerArguments -Wait -PassThru

$exitcode = $installProcess.ExitCode
Write-Host "[INSDL] Software Installation Exit Code is $exitcode"
if ($installProcess.ExitCode -eq 0) {
    # Installation was successful
    Write-Host "[INSDL] Installation Completed"
}
else {
    # Installation failed
    Write-Error "[INSDL] Installation Failed"
    Remove-Item -Path $installerDir -Recurse -Force -Confirm:$false
    Stop-Transcript
    exit 1
}

#### Step 4 - Run Install
Write-Host "[INSSW] Running Installer to Download Software"
$installerArguments = "/configure `"$configPath`""
$installProcess = Start-Process -FilePath "$installerTempPath\setup.exe" -ArgumentList $installerArguments -Wait -PassThru

$exitcode = $installProcess.ExitCode
Write-Host "[INSSW] Software Installation Exit Code is $exitcode"
if ($installProcess.ExitCode -eq 0) {
    # Installation was successful
    Write-Host "[INSSW] Installation Completed"
}
else {
    # Installation failed
    Write-Error "[INSSW] Installation Failed"
    Remove-Item -Path $installerDir -Recurse -Force -Confirm:$false
    Stop-Transcript
    exit 1
}

Set-Location "C:\temp"
Stop-Transcript

Start-Sleep -Seconds 10

Remove-Item -Path $installerTempPath -Recurse -Force -Confirm:$false
Remove-Item -Path $installerDir -Recurse -Force -Confirm:$false

exit 0