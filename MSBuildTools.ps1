if ($null -eq (Get-Module VSSetup)) {
  Install-Module VSSetup
}
Import-Module VSSetup

try {
  Import-Module ".\ext\BinPosh.VSSetup\Get-VSInstallDir\BinPosh.GVSID.psd1"
  Import-Module ".\ext\BinPosh.VSSetup\Enter-VSDevEnv\BinPosh.EVSDE.psd1"
}
catch {
  git.exe submodule init
  git.exe submodule sync
  Import-Module ".\ext\BinPosh.VSSetup\Get-VSInstallDir\BinPosh.GVSID.psd1"
  Import-Module ".\ext\BinPosh.VSSetup\Enter-VSDevEnv\BinPosh.EVSDE.psd1"
}

$Filter = (Get-Content .\MSBuildDeps.txt).Split("`n")
$VSInstallDir = Get-VSInstallDir -Prerelease -Filter $Filter
Write-Host $VSInstallDir
Enter-VSDevEnv -VsInstallDir $VSInstallDir

# cmd.exe (Get-ChildItem $VSInstallDir -Filter 'vcvarsall.bat' -Recurse -File).FullName -{
