$packageName = 'msiafterburner'
$url = 'http://download.msi.com/uti_exe/vga/MSIAfterburnerSetup.zip?__token__=' + $(Invoke-RestMethod https://www.msi.com/api/v1/get_token)
$checksum = 'c9c487321c44982a54e9a7f016b4d3e91394c23f424976f9dfa40c99e5f9fb95'
$checksumtype = 'sha256'
$unpackDir = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
$unpackFile = Join-Path $unpackDir 'afterburner.zip'
$fileType = 'exe'
$silentArgs = '/S'

Get-ChocolateyWebFile $packageName $unpackFile $url -Checksum $checksum -ChecksumType $checksumtype
Get-ChocolateyUnzip -fileFullPath $unpackFile -destination $unpackDir
$file = (Get-ChildItem -Path $unpackDir -Recurse | Where-Object {$_.Name -match "MSIAfterburnerSetup.*.exe$"}).fullname

$waitseconds = 2
foreach($procstring in @("MSIAfterburner*","RTSS","EncoderServer*","RTSSHooksLoader*"))
{
  Write-Output "Checking whether process matching $procstring is running..."
  for($i = 1; $i -le 2; $i++)
  {
    $procobj = Get-Process $procstring -ErrorAction SilentlyContinue
    if($procobj -eq $null)
    {
#      Write-Output " SUCCESS - No process matching $procstring is running"
      break
    }
    Stop-Process -Name $procstring
#    Write-Output " Try # $i : Waiting $waitseconds seconds for process to terminate..."
    Start-Sleep -s $waitseconds
  }
}

Install-ChocolateyInstallPackage $packageName $fileType $silentArgs $file 
Remove-Item $unpackFile -Recurse -Force
Remove-Item $file -Recurse -Force
