Function Install-RegistrySettings {

  [CmdletBinding()]
  Param()

  $settings = Get-Config registry

  Foreach ($setting in $settings) {

    If (-not (Test-Path $setting.key)) {

      New-Item -Path $setting.key -Force

    }

    Foreach ($entry in $setting.entries) {

      Remove-ItemProperty -Path $setting.key -Name $entry.name -Force -ErrorAction SilentlyContinue
      New-ItemProperty -Path $setting.key -Name $entry.name -Type $entry.type -Value $entry.value -ErrorAction SilentlyContinue

    }

  }

}
