$script:modules = New-Object System.Collections.ArrayList

$moduleDirs = Get-ChildItem -Path "$PSScriptRoot/../features" -Directory

Foreach ($m in $moduleDirs) {

  Import-Module -Name $m.FullName
  $script:modules.Add($m.Name) | Out-Null

}


Function Invoke-ModuleFunction {

  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$FunctionName,
    [Parameter(ValueFromPipeline = $true)]
    [ValidateNotNullOrEmpty()]
    [string[]]$ModuleName = $script:modules,
    $ArgumentList = @{}
  )

  Begin {

    $verb, $noun = $FunctionName -split "-"

  }

  Process {

    Foreach ($m in $ModuleName) {

      & "$verb-$m$noun" @ArgumentList

    }

  }

}
