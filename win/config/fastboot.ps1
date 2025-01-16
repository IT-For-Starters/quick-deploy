
#### Changable Variables!
$scriptLocation = "C:\temp\quick-deploy\config\fastboot"





#### Step 0 - Init session
$timestamp = Get-Date -Format "yyyy-MM-dd HH-mm"
Start-Transcript -Path "$scriptLocation\LOG_$timestamp.txt"


Try {
    Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberBootEnabled"
}
Catch {
    Write-Error '[FATAL] The key does not exist'
    Stop-Transcript
    exit 101
}
 
$registrykey = Get-ItemPropertyValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberBootEnabled"
 
if ($registrykey -eq '1') {
    Write-Host '[CHANGE] Disabling fast startup'
    try {
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name "HiberBootEnabled" -Value '0'
        Write-Host '[INFO] Fast startup disabled successfully'
    }
    catch {
        Write-Error "[FATAL] An error occured: $($_)"
        Stop-Transcript
        exit 102
    }
   
 
}
elseif ($registrykey -eq '0') {
    Write-Host '[NOCHANGE] Fast startup is already disabled'
 
}
else {
    Write-Error '[FATAL] The value of HiberBootEnabled is neither 1 or 0'
    Stop-Transcript
    exit 103
}



Stop-Transcript
exit 0