Function Install-RegistrySettings {

  [CmdletBinding()]
  Param()

  $settings = Get-Config registrysettings

  Foreach ($setting in $settings) {

    If (-not (Test-Path $setting.path)) {

      New-Item -Path $setting.path -Force

    }

    Remove-ItemProperty -Path $setting.path -Name $setting.Name -Force -ErrorAction SilentlyContinue

    New-ItemProperty -Path $setting.path -Name $setting.name -Type $setting.type -Value $setting.value -ErrorAction SilentlyContinue

  }

}
