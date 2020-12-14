
Function Test-IsElevated {

  [CmdletBinding()]
  Param()

  $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
  $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

}


Function Start-ElevatedProcess {

  [CmdletBinding()]
  Param()

  $powershellMappings = @{
    Core    = "pwsh"
    Desktop = "powershell"
  }

  If ($PSEdition -in $powershellMappings.Keys) {
    $psCommand = $powershellMappings.$PSEdition
  }
  Else {
    throw "Unknown PowerShell edition"
  }

  Start-Process -FilePath $psCommand -ArgumentList @("-File", "`"$PSCommandPath`"", "-Elevated") -Verb RunAs

}
