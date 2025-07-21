{ pkgs, lib, ... }:
let
  askpassScript = pkgs.writeShellScriptBin "1password-askpass" ''
    #!${pkgs.runtimeShell}
    op read 'op://Private/Sudo password/password'
  '';

  agentSocket =
    if pkgs.stdenv.isDarwin then
      ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"''
    else
      "~/.1password/agent.sock";

  op-ssh-sign =
    if pkgs.stdenv.isLinux then
      lib.getExe' pkgs._1password-gui "op-ssh-sign"
    else
      "${pkgs._1password-gui}/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
in
{
  config = {
    home.packages = [
      pkgs._1password-cli
    ];

    home.sessionVariables.SUDO_ASKPASS = toString askpassScript;
    programs.fish.shellAbbrs.s = "sudo --askpass";
    programs.ssh.extraConfig = ''
      IdentityAgent ${agentSocket}
    '';

    programs.git.signing = {
      signByDefault = true;
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG5fbZ1KwrHKB+ItUQ5CRhjDVztrVBs4ZgULBkZHs2Iw";
      format = "ssh";
      signer = op-ssh-sign;
    };
  };
}
