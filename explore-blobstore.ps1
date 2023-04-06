param()

function Get-PossibleVersions() {
    $Versions = @()
    $Major = 6
    $Minor = 40 # a bit above the current version
    $Patch = 0
    $Build = 0

    while ($true) {
        # add version
        $Version = "$($Major).$($Minor).$($Patch).$($Build)"
        $Versions += $Version

        # decrement version
        # - Build in [0, 9]
        # - Patch in [0, 20] # have never seen a patch > 20
        # - Minor in [0, 40] # 6.x and 5.x have not progressed beyond 40
        # - Major in [5, 6]  # 6.x and 5.x
        $Build -= 1
        if ($Build -lt 0) {
            $Build = 9
            $Patch -= 1
        }
        if ($Patch -lt 0) {
            $Patch = 20
            $Minor -= 1
        }
        if ($Minor -lt 0) {
            $Minor = 40
            $Major -= 1
        }
        if ($Major -lt 5) {
            break
        }
    }

    return $Versions
}

function Main() {
    # generate all possible versions
    $Versions = Get-PossibleVersions
    #$Versions = @( "6.20.7.0", "6.37.5.5" )
    Write-Host "Generated $($Versions.Length) possible versions."

    # check which versions are available, parallelized
    $AvailableVersions = @($Versions | ForEach-Object -Parallel {
            # define functions in parallelized scope
            function Get-BlobDownloadURL([string] $Version) {
                return "https://dbpdfusprodmsixstorage.blob.core.windows.net/downloads/Db.App_$($Version)/Db.App_$($Version)_x86_x64_ARM.msixbundle"
            }
        
            function Test-VersionAvailable([string] $Version) {
                $URL = Get-BlobDownloadURL -Version $Version
        
                try {
                    #Write-Information "testing $Version at $URL ..."
                    Invoke-WebRequest -Uri $URL -Method HEAD -ErrorAction Stop
                    return $true
                }
                catch {
                    #if ($_.Exception.Response.StatusCode -eq 404) {
                    if ($_.Exception.Message -eq "Response status code does not indicate success: 404 (The specified blob does not exist.).") {
                        return $false
                    } 
    
                    Write-Host "non-404 error:"
                    Write-Host $_
                    return $false
                }
            }

            # do work
            $Version = $_
            if (Test-VersionAvailable -Version $Version) {
                Write-Host " Test $Version OK" -ForegroundColor Green
                return [PSCustomObject]@{
                    Name = $Version
                    URL  = (Get-BlobDownloadURL -Version $Version)
                }
            }
            Write-Host " Test $Version"
        })

    # write available versions to file version.json
    $AvailableVersions | ConvertTo-Json | Out-File -FilePath "$PSScriptRoot\versions.json" -Encoding UTF8 -Force

    # write available versions to console (as a backup)
    Write-Host "`n`n`nAvailable versions:"
    $AvailableVersions | Format-Table
}
$DebugPreference = "Continue"
$InformationPreference = "Continue"
$ErrorActionPreference = "Stop"
Main
