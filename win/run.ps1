
#### Changable Variables!
$githubLocation = "https://api.github.com/repos/it-for-starters/quick-deploy/contents/win"

$destLocation = "C:\temp\quick-deploy\scripts_to_run"


function DownloadGithubFolder {
    param (
        [string]$url
    )

    # Fetch the list of repository contents
    try {
        $githubresponse = Invoke-RestMethod -Uri $url
    } catch {
        Write-Error "Failed to fetch repository contents. Check the repository URL or network connection."
        return $false
    }


    foreach ($item in $githubresponse) {
        if ($item.type -eq "dir") {
            DownloadGithubFolder -url $item.url
        } else {
            $partialPath = $item.path.Replace("/","\")
            $newPath = "$destLocation\$partialPath"
            $newPathDir = Split-Path -Path $newPath -Parent
            
            if (!(Test-Path -Path $newPathDir -PathType Container)) {
                New-Item -ItemType Directory -Path $newPathDir
            }
            try {
                Invoke-WebRequest -Uri $item.download_url -OutFile $newPath
                if ([System.IO.Path]::GetExtension($newPath) -eq ".ps1") {
                    Write-Host "Running file $newPath"
                    & $newPath
                }
                
            } catch {
                Write-Error "Failed to download file $($newPath)"
                return $false
            }


            
        }
    }

    

}

DownloadGithubFolder -url $githubLocation

#Stop-Transcript
exit 0