{ lib, config, pkgs, ... }:
let
  cfg = config.custom.applications.shell.zsh;
in
{
  options = {
    custom.applications.shell.zsh = {
      enable = lib.mkEnableOption "Enable zsh shell";
    };
  };

  config = lib.mkIf cfg.enable
    {
      users.defaultUserShell = pkgs.zsh;
      programs.zsh.enable = true;
    };
}
