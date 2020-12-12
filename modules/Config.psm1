Function Import-Config {

  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Path
  )

  $script:config = Get-Content -Path $Path -Encoding utf8 `
  | ConvertFrom-Yaml

}


Function Get-Config {

  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Name
  )

  $script:config.$Name

}
