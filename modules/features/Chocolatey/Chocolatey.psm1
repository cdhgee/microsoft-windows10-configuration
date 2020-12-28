Function Start-Configuration {

  [CmdletBinding()]
  Param()

  Install-Chocolatey
  Install-ChocolateyPackages

}

Function Install-Chocolatey {

  [CmdletBinding()]
  Param()

  ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1")) `
  | Invoke-Expression

  & "C:\ProgramData\chocolatey\bin\choco.exe" feature enable -n allowGlobalConfirmation

}


Function Install-ChocolateyPackages {

  [CmdletBinding()]
  Param()

  Get-Config -Name chocolatey -PipelineVariable package `
  | ForEach-Object {
    & "C:\ProgramData\chocolatey\bin\choco.exe" install $package
  }

}
