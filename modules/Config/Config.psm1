$script:config = @{}

Function Get-Config {

  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Name
  )

  Write-Host (Get-Item -Path $PSCommandPath).Parent.FullName

  If ($Name -notin $script:config.Keys) {

    $script:config.$Name = Get-Content "$($MyInvocation.PSScriptRoot)/config/$Name.yaml" `
    | ConvertFrom-Yaml

  }

  $script:config.$Name

}
