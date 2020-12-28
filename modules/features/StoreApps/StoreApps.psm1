
Function Start-Configuration {

  $packages = Get-Config -Name "storeapps"

  Foreach ($package in $packages) {

    Get-AppxPackage -Name $package | Remove-AppxPackage

  }

}
