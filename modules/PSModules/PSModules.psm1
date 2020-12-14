
Function Install-PowerShellModules {

  [CmdletBinding()]
  Param()

  Get-Config -Name "psmodules" -PipelineVariable module `
  | Foreach-Object {
    Install-Module -Name $module -Scope CurrentUser
  }

}
