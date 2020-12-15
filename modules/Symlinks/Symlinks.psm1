
Function Install-Symlinks {

  [CmdletBinding()]
  Param()

  $symlinks = Get-Config -Name symlinks

  Foreach ($symlink in $symlinks) {

    $path = "$($env:UserProfile)/$($symlink.path)"
    $target = "$($env:OneDriveConsumer)/Roaming/$($symlink.target)"

    If (Test-Path -Path $target) {

      $source = Join-Path -Path $path -ChildPath $symlink.name

      # If an existing file/directory exists there, rename it to .old
      If (Test-Path -Path $source) {
        Get-Item -Path $source | Rename-Item -NewName "$($symlink.name).old"
      }

      # Create new symlink
      New-Item -ItemType SymbolicLink -Path $path -Name $symlink.name -Target $target

    }

  }

}
