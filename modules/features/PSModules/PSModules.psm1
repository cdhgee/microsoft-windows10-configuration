
Function Start-Configuration {

  [CmdletBinding()]
  Param()

  $modules = Get-Config -Name "psmodules"
  Install-Module -Name $modules -Scope CurrentUser


}
