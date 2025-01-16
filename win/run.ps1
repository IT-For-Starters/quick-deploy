
#### Changable Variables!
$githubLocation = "https://api.github.com/repos/it-for-starters/quick-deploy/contents/win"
$BearerToken = Get-Content -Path "C:\temp\key.key"
$Headers = @{
    Authorization = "Bearer $BearerToken"
}


$destLocation = "C:\temp\quick-deploy\scripts_to_run"
Start-Transcript -Path "$destLocation\LOG_$timestamp.txt"

function DownloadGithubFolder {
    param (
        [string]$url
    )

    Write-Host "Processing URL $url"

    # Fetch the list of repository contents
    try {
        $githubresponse = Invoke-RestMethod -Uri $url -Headers $Headers
    }
    catch {
        Write-Error "Failed to fetch repository contents. Check the repository URL or network connection."
        return $false
    }


    foreach ($item in $githubresponse) {
        if ($item.type -eq "dir") {
            Write-Host "Is folder. Will recurse."
            DownloadGithubFolder -url $item.url
        }
        else {
            Write-Host "Is file. Will download."
            $partialPath = $item.path.Replace("/", "\")
            $newPath = "$destLocation\$partialPath"
            $newPathDir = Split-Path -Path $newPath -Parent
            
            if (!(Test-Path -Path $newPathDir -PathType Container)) {
                Write-Host "Path doesn't exist, will create"
                New-Item -ItemType Directory -Path $newPathDir
            }
            if ($item.name -ne "run.ps1") {
                Write-Host "Downloading now"
                try {
                    Invoke-WebRequest -Uri $item.download_url -OutFile $newPath
                    if ([System.IO.Path]::GetExtension($newPath) -eq ".ps1") {
                        Write-Host "Running file $newPath"
                        & $newPath
                    }
                    
                }
                catch {
                    Write-Error "Failed to download file $($newPath)"
                    return $false
                }
            }
            


            
        }
    }

    return $true;

    

}

DownloadGithubFolder -url $githubLocation


Stop-Transcript
exit 0