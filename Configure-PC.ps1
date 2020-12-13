[CmdletBinding()]
Param(
  [switch]$Elevated,
  [switch]$SkipElevated
)


Function Initialize-Settings {

  [CmdletBinding()]
  Param()

  #Install-PackageProvider NuGet -Force
  If ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne "Trusted") {
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
  }

  # Install YAML module so we can use it with settings
  If (-not (Get-Module -name powershell-yaml)) {
    Install-Module -Name powershell-yaml -Scope CurrentUser
  }

}


Function Import-ScriptModules {

  [CmdletBinding()]
  Param()

  $modules = @(
    "Config"
    "Chocolatey"
    "Console"
    "Symlinks"
    "PSModules"
    "Elevated"
    "Registry"
  )

  Foreach ($module in $modules) {

    Import-Module -Name "$PSScriptRoot/modules/$module.psm1"

  }

}


Function Start-Configuration {

  [CmdletBinding()]
  Param()

  Initialize-Settings

  Install-RegistrySettings
  exit

  Set-ConsoleTheme
  Set-ConsoleLinks
  Remove-StoreApps
  Install-Chocolatey
  Install-ChocolateyPackages
  Install-PowerShellModules
  Install-Symlinks

}

Function main {

  [CmdletBinding()]
  Param()

  Import-ScriptModules

  If (Test-IsElevated) {

    Start-Configuration

  }
  Else {

    Start-ElevatedProcess

  }

}

main
