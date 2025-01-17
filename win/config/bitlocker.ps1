#### Changable Variables!
$scriptLocation = "C:\temp\quick-deploy\config\bitlocker"
$recoveryLocation = "C:\temp"

#### Step 0 - Init session
$timestamp = Get-Date -Format "yyyy-MM-dd HH-mm"
Start-Transcript -Path "$scriptLocation\LOG_$timestamp.txt"

$pcname = $env:COMPUTERNAME
$serialnumber = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber

# if (!(Test-Path -Path $recoveryKeyLocation -PathType Container)) {
#     New-Item -ItemType Directory -Path $recoveryKeyLocation
# }
# $acl = Get-Acl $recoveryKeyLocation
# $acl.SetAccessRuleProtection($true, $false) # Disable inheritance (remove inherited permissions)
# $adminGroup = [System.Security.Principal.NTAccount]"BUILTIN\Administrators"
# $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($adminGroup, "FullControl", "Allow")
# $acl.AddAccessRule($accessRule)
# Set-Acl -Path $recoveryKeyLocation -AclObject $acl

try {
    # Activate BitLocker on the C: drive 
    Enable-BitLocker -MountPoint "C:" -TpmProtector -UsedSpaceOnly -SkipHardwareTest
    Manage-BDE -Protectors -Add "C:" -RecoveryPassword | Out-Null

    # Get the BitLocker recovery key 
    $recoveryKey = (Get-BitLockerVolume -MountPoint "C:").KeyProtector | Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' } 

    # Save the recovery key to a file with computer name 
    $recoveryKeyLocation = "$recoveryLocation\RecoveryKey_$($serialnumber)_$($pcname).txt"
    $recoveryKey | ConvertTo-Json | Out-File -FilePath $recoveryKeyLocation

    Write-Host "BitLocker has been activated and the recovery key has been saved to $recoveryKeyLocation"
}
catch {
    Disable-Bitlocker -MountPoint "C:"
    Write-Host "Error message: $($_.Exception.Message)"
    Write-Host "Stack trace: $($_.Exception.StackTrace)"
    Write-Host "Inner Exception: $($_.Exception.InnerException)"
    Stop-Transcript
    exit 1
}



Stop-Transcript
exit 0