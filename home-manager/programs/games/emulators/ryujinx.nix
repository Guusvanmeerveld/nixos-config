{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.games.emulators.ryujinx;
in {
  options = {
    custom.programs.games.emulators.ryujinx = {
      enable = lib.mkEnableOption "Enable Ryujinx Open-source Nintendo switch emulator";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [custom.ryubing];
  };
}
