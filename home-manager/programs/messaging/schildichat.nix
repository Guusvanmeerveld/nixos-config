{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.messaging.schildichat;
in {
  options = {
    custom.programs.messaging.schildichat = {
      enable = lib.mkEnableOption "Enable Schildichat matrix client";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      schildichat-desktop
    ];

    nixpkgs.config.permittedInsecurePackages = [
      "schildichat-web-1.11.30-sc.2"
      "electron-25.9.0"
    ];
  };
}
