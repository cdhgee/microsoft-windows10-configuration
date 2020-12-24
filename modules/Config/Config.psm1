Function Import-Config {

  [CmdletBinding()]
  Param()

  $script:config = Get-ChildItem -Recurse -Path "$($PSScriptRoot)/../../config" -Filter "*.yaml" -PipelineVariable configFile `
  | Get-Content -Encoding utf8 -PipelineVariable yaml `
  | ConvertFrom-Yaml -AllDocuments -UseMergingParser

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

Import-Config
