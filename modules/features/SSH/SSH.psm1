Function Start-Configuration {

  [CmdletBinding()]
  Param()

  Add-SSHKeys
  Install-SSHServer

}


Function Add-SSHKeys {

  [CmdletBinding()]
  Param()

  $sshUserDir = "$($env:USERPROFILE)/.ssh"

  If (-not (Test-Path -Path $sshUserDir)) {
    New-Item -Path $sshUserDir -ItemType Directory
  }

  $comment = "$($env:USERNAME)@$($env:COMPUTERNAME)".ToLower()

  # Create an RSA keypair with no comment (other than this one)
  & ssh-keygen -t rsa -b 4096 -C "`"$comment`"" -f "`"$sshUserDir/id_rsa`"" -N "`"`""

  # Create an ED25519 keypair with no comment (other than this one)
  & ssh-keygen -t ed25519 -o -a 100 -C "`"$comment`"" -f "`"$sshUserDir/id_ed25519`"" -N "`"`""


}


Function Install-SSHServer {

  [CmdletBinding()]
  Param()

  # Install the SSH server
  Get-WindowsCapability -Online -Name "OpenSSH.Server*" `
  | Add-WindowsCapability

  # Automatically start the SSH server at boot
  Get-Service -Name sshd `
  | Set-Service -StartupType Automatic -PassThru `
  | Start-Service

}
