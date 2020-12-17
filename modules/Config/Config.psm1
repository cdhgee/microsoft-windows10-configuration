$script:config = @{}

Function Get-Config {

  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Name
  )

  If ($Name -notin $script:config.Keys) {

    $script:config.$Name = Get-Content "$($PSScriptRoot)/../../config/$Name.yaml" `
    | ConvertFrom-Yaml

  }

  $script:config.$Name

}
