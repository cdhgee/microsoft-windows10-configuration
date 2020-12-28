Function Set-ConsoleTheme {

  [CmdletBinding()]
  Param()

  # Types are not dynamically loaded in a script
  Add-Type -AssemblyName System.Drawing

  Get-ChildItem -Path "HKCU:/Console" | Remove-Item -Force

  # Note the console colors stored in the registry are BGR (blue is shifted left 16 bits, red is as is)

  $i = 0
  $console = Get-Config -Name console

  Foreach ($hexCode in $console.colors) {

    $color = [System.Drawing.ColorTranslator]::FromHtml($hexCode)

    # Cast to int is needed because [System.Drawing.Color] stores components as bytes
    # and doing a shift left on a byte results in a zero.
    $brg = ([int]$color.B -shl 16) -bor ([int]$color.G -shl 8) -bor [int]$color[0].R

    Set-ItemProperty -Path "HKCU:/Console" -Name "ColorTable$($i.ToString().PadLeft(2, "0"))" -Value $brg

    $i++
  }

  Set-ItemProperty -Path "HKCU:/Console" -Name "FaceName" -Value $console.fontface

  # Size 18
  Set-ItemProperty -Path "HKCU:/Console" -Name "FontSize" -Value $console.fontsize
  # Medium weight
  Set-ItemProperty -Path "HKCU:/Console" -Name "FontWeight" -Value $console.fontweight

}

Function Set-ConsoleLinks {

  $console = Get-Config -Name "console"

  Foreach ($l in $console.links) {

    $link = & "$PSScriptRoot/Get-Link.ps1" -Path "${env:APPDATA}/$l"

    $i = 0
    Foreach ($hexCode in $console.colors) {
      $link.ConsoleColors[$i] = $hexCode
      $i++
    }

    # Set Light/Dark Theme-Specific Colors
    if ($console.theme -eq "dark") {
      $link.PopUpBackgroundColor = 0xf
      $link.PopUpTextColor = 0x6
      $link.ScreenBackgroundColor = 0x0
      $link.ScreenTextColor = 0x1
    }
    else {
      $link.PopUpBackgroundColor = 0x0
      $link.PopUpTextColor = 0x1
      $link.ScreenBackgroundColor = 0xf
      $link.ScreenTextColor = 0x6
    }

    $link.Save()

  }


}
