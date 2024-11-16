{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.dm.emptty;
in {
  options = {
    custom.dm.emptty = {
      enable = lib.mkEnableOption "Enable emptty display manager";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [emptty];

    services.displayManager = {
      enable = true;
      execCmd = "${pkgs.emptty}/bin/emptty";
    };
  };
}
