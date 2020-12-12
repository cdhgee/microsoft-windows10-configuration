[CmdletBinding()]
Param(
  [switch]$Elevated,
  [switch]$SkipElevated
)

$config = @{
  chocoPackagesFile = "chocolatey-packages.txt"
  psModulesFile     = "powershell-modules.txt"
  consoleColorsFile = "console-colors.txt"
  storeAppsFile     = "store-apps.txt"
}

Function Initialize-ScriptVariables {

  [CmdletBinding()]
  Param()

  $script:powershellMappings = @{
    Core    = "pwsh"
    Desktop = "powershell"
  }

}

Function Initialize-Settings {

  [CmdletBinding()]
  Param()

  #Install-PackageProvider NuGet -Force
  Set-PSRepository PSGallery -InstallationPolicy Trusted

}


Function Install-Chocolatey {

  [CmdletBinding()]
  Param()

  ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) `
  | Invoke-Expression

  & "C:\ProgramData\chocolatey\bin\choco.exe" feature enable -n allowGlobalConfirmation

}


Function Get-ConfigFile {

  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Filename
  )

  # Lines that begin with a # are treated as comments, so strip them out
  Get-Content -Path "$PSScriptRoot/$Filename" -Encoding utf8 -PipelineVariable line `
  | Where-Object { $line[0] -ne "#" }
}

Function Install-ChocolateyPackages {

  [CmdletBinding()]
  Param()

  Get-ConfigFile -Filename $config.chocoPackagesFile -PipelineVariable package `
  | ForEach-Object {
    & "C:\ProgramData\chocolatey\bin\choco.exe" install $package
  }

}


Function Install-PowerShellModules {

  [CmdletBinding()]
  Param()

  Get-ConfigFile -Filename $config.psModulesFile -PipelineVariable module `
  | Foreach-Object {
    Install-Module -Name $module -Scope CurrentUser
  }

}

Function Set-ConsolePersonalization {

  [CmdletBinding()]
  Param()

  # Types are not dynamically loaded in a script
  Add-Type -AssemblyName System.Drawing

  Get-ChildItem -Path "HKCU:/Console" | Remove-Item -Force

  # Note the console colors stored in the registry are BGR (blue is shifted left 16 bits, red is as is)

  $i = 0
  $consoleColors = Get-ConfigFile -Filename $config.consoleColorsFile

  Foreach ($hexCode in $consoleColors) {

    $color = [System.Drawing.ColorTranslator]::FromHtml("#$hexCode")

    # Cast to int is needed because [System.Drawing.Color] stores components as bytes
    # and doing a shift left on a byte results in a zero.
    $brg = ([int]$color.B -shl 16) -bor ([int]$color.G -shl 8) -bor [int]$color[0].R

    Set-ItemProperty -Path "HKCU:/Console" -Name "ColorTable$($i.ToString().PadLeft(2, "0"))" -Value $brg

    $i++
  }

  Set-ItemProperty -Path "HKCU:/Console" -Name "FaceName" -Value "Cascadia Code PL"

  # Size 18
  Set-ItemProperty -Path "HKCU:/Console" -Name "FontSize" -Value 0x00120000
  # Medium weight
  Set-ItemProperty -Path "HKCU:/Console" -Name "FontWeight" -Value 400

  $links = @(
    "${ENV:APPDATA}/Microsoft/Windows/Start Menu/Programs/Windows PowerShell/Windows PowerShell.lnk"
    "${ENV:APPDATA}/Microsoft/Windows/Start Menu/Programs/Windows PowerShell/Windows PowerShell (x86).lnk"
    "${ENV:APPDATA}/Microsoft/Windows/Start Menu/Programs/System Tools/Command Prompt.lnk"
  )
  $theme = "Dark"

  Foreach ($l in $links) {

    $link = & "$PSScriptRoot/Get-Link.ps1" -Path $l

    $i = 0
    Foreach ($hexCode in $consoleColors) {
      $link.ConsoleColors[$i] = "#$hexCode"
      $i++
    }

    # Set Light/Dark Theme-Specific Colors
    if ($theme -eq "Dark") {
      $link.PopUpBackgroundColor = 0xf
      $link.PopUpTextColor = 0x6
      $link.ScreenBackgroundColor = 0x0
      $link.ScreenTextColor = 0x1
    }
    else {
      $link.PopUpBackgroundColor = 0x0
      $link.PopUpTextColor = 0x1
      $link.ScreenBackgroundColor = 0xf
      $link.ScreenTextColor = 0x6
    }

    $link.Save()

  }


}

Function Install-Shortcuts {

  [CmdletBinding()]
  Param()

  $shortcuts = @(
    @{
      Path   = "C:\Users\JCHQDGEE\AppData\Roaming\Microsoft"
      Name   = "Signatures"
      Target = "C:\Users\JCHQDGEE\OneDrive - Smiths Group\Signatures"
    },
    @{
      Path   = "C:\Users\JCHQDGEE\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe"
      Name   = "LocalState"
      Target = "C:\Users\JCHQDGEE\OneDrive\Roaming\Windows Terminal Settings"
    }
  )

  Foreach ($shortcut in $shortcuts) {

    If (Test-Path -Path $shortcut.Target) {

      # If an existing file/directory exists there, rename it to .old
      $source = Join-Path -Path $shortcut.Path -ChildPath $shortcut.Name
      If (Test-Path -Path $source) {
        Get-Item -Path $source | Rename-Item -NewName "$($shortcut.Name).old"
      }

      # Create new symlink
      New-Item -ItemType SymbolicLink -Path $shortcut.Path -Name $shortcut.Name -Target $shortcut.Target

    }

  }

}


Function Remove-StoreApps {

  $packages = Get-ConfigFile -Filename $config.storeAppsFile

  Foreach ($package in $packages) {

    Get-AppxPackage -Name $package | Remove-AppxPackage

  }

}

Function Invoke-ElevatedCommands {

  [CmdletBinding()]
  Param()

  Initialize-ScriptVariables
  Initialize-Settings
  Install-Chocolatey
  Install-ChocolateyPackages
  Install-PowerShellModules
  Install-Shortcuts

}


Function Invoke-UnelevatedCommands {

  [CmdletBinding()]
  Param()

  Set-ConsolePersonalization
  Remove-StoreApps

}

Function main {

  [CmdletBinding()]
  Param()

  # Skip running most of the regular steps if the script had to elevate
  # itself as these would have been run when not elevated.

  If (-not $Elevated) {

    Invoke-UnelevatedCommands

  }

  # Skip all the elevated commands if the SkipElevated switch was supplied
  If (-not $SkipElevated) {

    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    If ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

      Invoke-ElevatedCommands

    }
    Else {

      If ($PSEdition -in $script:powershellMappings.Keys) {
        $psCommand = $script.powershellMappings.$PSEdition
      }
      Else {
        throw "Unknown PowerShell edition"
      }

      Start-Process -FilePath $psCommand -ArgumentList @("-File", "`"$PSCommandPath`"", "-Elevated") -Verb RunAs

    }
  }

}

main
