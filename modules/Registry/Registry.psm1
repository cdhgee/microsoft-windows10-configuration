Function Install-RegistrySettings {

  [CmdletBinding()]
  Param()

  $settings = Get-Config registry

  Foreach ($setting in $settings) {

    If (-not (Test-Path $setting.key)) {

      New-Item -Path $setting.key -Force

    }

    # Using -Force will overwrite any existing property setting
    New-ItemProperty -Path $setting.key -Name $setting.name -Type $setting.type -Value $setting.value -Force -ErrorAction SilentlyContinue

  }

}
