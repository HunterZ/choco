$packageName = 'msiafterburner'
$installerType = 'exe'
$silentArgs = '/S'
$validExitCodes = @(0)
$scriptPath = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$ahkFile = Join-Path $scriptPath 'chocolateyUninstall.ahk'
$ahkExe = 'AutoHotKey'
$ahkRun = "$Env:Temp\$(Get-Random).ahk"
$packageSearchRegex = '^(MSI Afterburner|RivaTuner Statistics Server).*'

$toolsPath = Split-Path $MyInvocation.MyCommand.Definition
. $toolsPath\helpers.ps1

Stop-Afterburner

Copy-Item $ahkFile "$ahkRun" -Force
Start-Process $ahkExe $ahkRun

Get-ItemProperty `
  -Path @('HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
          'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
          'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*') `
  -ErrorAction:SilentlyContinue `
| Where-Object `
  {$_.DisplayName -Match $packageSearchRegex} `
| ForEach-Object `
  {Uninstall-ChocolateyPackage `
    -PackageName "$packageName" `
    -FileType "$installerType" `
    -SilentArgs "$($silentArgs)" `
    -File "$($_.UninstallString.Replace('"',''))" `
    -ValidExitCodes $validExitCodes}

Remove-Item "$ahkRun" -Force
