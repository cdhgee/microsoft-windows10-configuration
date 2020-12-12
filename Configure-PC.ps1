[CmdletBinding()]
Param(
  [switch]$Elevated,
  [switch]$SkipElevated
)


Function Initialize-Settings {

  [CmdletBinding()]
  Param()

  #Install-PackageProvider NuGet -Force
  Set-PSRepository PSGallery -InstallationPolicy Trusted

}


Function Invoke-ElevatedCommands {

  [CmdletBinding()]
  Param()

  Initialize-ScriptVariables
  Initialize-Settings
  Install-Chocolatey
  Install-ChocolateyPackages
  Install-PowerShellModules
  Install-Symlinks

}


Function Invoke-UnelevatedCommands {

  [CmdletBinding()]
  Param()

  Set-ConsoleTheme
  Set-ConsoleLinks
  Remove-StoreApps

}


Function main {

  [CmdletBinding()]
  Param()



  $modules = @(
    "Config"
    "Chocolatey"
    "Console"
    "Symlinks"
    "PSModules"
    "Elevated"
  )

  Foreach ($module in $modules) {

    Import-Module -Name "$PSScriptRoot/modules/$module.psm1"

  }

  Import-Config -Path "$PSScriptRoot/config/config.json"

  # Skip running most of the regular steps if the script had to elevate
  # itself as these would have been run when not elevated.

  If (-not $Elevated) {

    Invoke-UnelevatedCommands

  }

  # Skip all the elevated commands if the SkipElevated switch was supplied
  If (-not $SkipElevated) {

    If (Get-IsElevated) {

      Invoke-ElevatedCommands

    }
    Else {

      Start-ElevatedProcess

    }
  }

}

main
