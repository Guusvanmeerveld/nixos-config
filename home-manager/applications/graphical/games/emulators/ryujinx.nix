{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.games.emulators.ryujinx;
in {
  options = {
    custom.applications.graphical.games.emulators.ryujinx = {
      enable = lib.mkEnableOption "Enable Ryujinx Open-source Nintendo switch emulator";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [custom.ryubing];
  };
}
