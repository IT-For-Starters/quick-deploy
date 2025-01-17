
#### Changable Variables!
$scriptLocation = "C:\temp\quick-deploy\software\multi-driver"

$DELLinstallerUrl = "https://downloads.dell.com/FOLDER11914075M/1/Dell-Command-Update-Application_6VFWW_WIN_5.4.0_A00.EXE";
$DELLinstallerName = "dell_installer.exe";
$DELLinstallerArguments = "/s";

$LENOVOzipUrl = "https://download.lenovo.com/pccbbs/thinkvantage_en/metroapps/Vantage/LenovoCommercialVantage_10.2501.15.0_v3.zip";
$LENOVOzipName = "lenovo_vantage.zip";



#### Step 0 - Init session
$timestamp = Get-Date -Format "yyyy-MM-dd HH-mm"
Start-Transcript -Path "$scriptLocation\LOG_$timestamp.txt"


#### Step 0.1 - Check Type
Write-Host "[INFO] Checking Manufacturer in BIOS"
$manufacturer = (Get-CimInstance -ClassName Win32_BIOS).Manufacturer
if (!$manufacturer) {
    Write-Host "[WARN] Cannot find Manufacturer in BIOS, will use WMI"
    $manufacturer = (Get-WmiObject -Class Win32_ComputerSystem).Manufacturer
}

if ($manufacturer -ilike "*dell*") {
    $installType = "DELL"
}
elseif ($manufacturer -ilike "*lenovo*") {
    $installType = "LENOVO"
}
else {
    $installType = "OTHER"
    Write-Host "[ABORT] No Valid Manufacturer found, will exit"
    Stop-Transcript
    exit 0
}

$installerDir = "$scriptLocation\files";
Write-Host "[DL] Checking if installer Directory Exists"
if (!(Test-Path -Path "$installerDir" -PathType Container)) {
    Write-Host "[DL] No - creating..."
    New-Item -Path "$installerDir" -ItemType Directory | Out-Null
}
else {
    Write-Host "[DL] Yes - proceeding..."
}




if ($installType -eq "DELL") {
    #### Step 1 - Download Installer
    $installerPath = "$installerDir\$DELLinstallerName"

    Write-Host "[DL] Checking if installer exists already"
    if (!(Test-Path -Path "$installerPath" -PathType Leaf)) {
        Write-Host "[DL] No - downloading..."
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($DELLinstallerUrl, $installerPath)
    }
    else {
        Write-Host "[DL] Yes - proceeding..."
    }

    #### Step 2 - Run Installer
    Write-Host "[INS] Running Installer"
    $installProcess = Start-Process -FilePath "$installerPath" -ArgumentList $DELLinstallerArguments -Wait -PassThru
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

}

if ($installType -eq "LENOVO") {
    Set-Location -Path $installerDir

    #### Step 1 - Download Installer ZIP
    $installerPath = "$installerDir\$LENOVOzipName"

    Write-Host "[DL] Checking if installer exists already"
    if (!(Test-Path -Path "$installerPath" -PathType Leaf)) {
        Write-Host "[DL] No - downloading..."
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($LENOVOzipUrl, $installerPath)
    }
    else {
        Write-Host "[DL] Yes - proceeding..."
    }

    #### Step 2 - Extract ZIP
    Expand-Archive -Path $installerPath -DestinationPath $installerDir -Force

    #### Step 3 - Run Install Script
    if (!(Test-Path -Path "$installerDir\lenovo-commercial-vantage-install.ps1" -PathType Leaf)) {
        Write-Host "[ERROR] Installer script not found"
    }
    else {
        Write-Host "[LENOVO] Running Installer Script"
        & "$installerDir\lenovo-commercial-vantage-install.ps1"
    }

    Set-Location -Path "C:\temp"

    
}







Remove-Item -Path $installerDir -Recurse -Force -Confirm:$false
Stop-Transcript
exit 0