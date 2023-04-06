param()

function Main() {

    # read versions from file
    $Versions = Get-Content -Path "versions.json" -Raw | ConvertFrom-Json


    # download all versions using azcopy
    $Versions | ForEach-Object {
        $Version = $_.Name
        $URL = $_.URL

        $FileName = "Db.App_$($Version)_x86_x64_ARM.msixbundle"
        $Destination = "$PSScriptRoot\dl\$FileName"
        if (Test-Path -Path $Destination) {
            Write-Host " $Version already downloaded"
            return
        }

        Write-Host "Downloading $Version as $FileName ..."
        .\azcopy.exe copy "$URL" "$Destination"
    }

}
$DebugPreference = "Continue"
$InformationPreference = "Continue"
$ErrorActionPreference = "Stop"
Main
