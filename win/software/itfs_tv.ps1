$timestamp = Get-Date -Format "yyyy-MM-dd HH-mm"
Start-Transcript -Path "C:\temp\quick-deploy\software\teamviewer\LOG_$timestamp.txt"

$serialnumber = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber
$pcname = $env:COMPUTERNAME

$manufacturer = (Get-CimInstance -ClassName Win32_BIOS).Manufacturer
if (!$manufacturer) {
    Write-Host "[WARN] Cannot find Manufacturer in BIOS, will use WMI"
    $manufacturer = (Get-WmiObject -Class Win32_ComputerSystem).Manufacturer
}
$model = (Get-CimInstance -ClassName Win32_BIOS).Model
if (!$model) {
    Write-Host "[WARN] Cannot find Model Name in BIOS, will use WMI"
    $model = (Get-WmiObject -Class Win32_ComputerSystem).Model
}

$teamviewerServices = Get-Service | Where-Object { $_.DisplayName -like "Teamviewer*" }

Write-Host "Current Serial Number: $serialnumber"
Write-Host "Current PC Name: $pcname"
Write-Host "Current Manufacturer: $manufacturer"
Write-Host "Current Model: $model"

$teamviewerAlias = ""

if ($null -ne $serialnumber -and $serialnumber -ne "") {
    Write-Host "[INFO] Serial Number isn't empty."
    if ($serialnumber -eq $pcname) {
        Write-Host "[INFO] PC Name is identical to Serial Number"
        $teamviewerAlias += $serialnumber
    }
    else {
        Write-Host "[INFO] PC Name is different to Serial Number, will include both"
        $teamviewerAlias += $serialnumber
        $teamviewerAlias += "_"
        $teamviewerAlias += $pcname
    }
}
else {
    Write-Host "[INFO] Serial Number is empty. Will use PC Name"
    $teamviewerAlias += $pcname
}

if ($teamviewerServices) {
    Write-Error "[ERROR] Teamviewer is already installed."
    exit 101
}
else {
    Write-Host "[INFO] Teamviewer not present, will install"
    $creds = Get-Content -Path "C:\temp\teamviewer.json" | ConvertFrom-Json
    Start-BitsTransfer -Source "https://www.itforstarters.com/assets/dl/tv_host_nb_2024_03.msi" -Destination "C:\temp\quick-deploy\software\teamviewer\tvhostnb.msi"
    $installArguments = "/i C:\temp\quick-deploy\software\teamviewer\tvhostnb.msi /qn CUSTOMCONFIGID=$($creds.customconfigid) APITOKEN=$($creds.apitoken) ASSIGNMENTOPTIONS=`"--alias $teamviewerAlias --grant-easy-access`""
    $installationProcess = Start-Process -FilePath "msiexec.exe" -ArgumentList $installArguments -Wait -PassThru
    
    $exitcode = $installationProcess.ExitCode

    Write-Host "[INFO] Software Installation Exit Code is $exitcode"

    if ($installationProcess.ExitCode -eq 0) {
        # Installation was successful
        Write-Host "[SUCCESS] Teamviewer Install was Successful"
        Remove-Item "C:\temp\quick-deploy\software\teamviewer\tvhostnb.msi" -Confirm:$false
    }
    else {
        # Installation failed
        Write-Error "[ERROR] Installation Failed"
        Remove-Item "C:\temp\quick-deploy\software\teamviewer\tvhostnb.msi" -Confirm:$false
        exit 1
    }
}




Stop-Transcript
exit 0