{ lib, config, ... }:
let
  cfg = config.custom.applications.graphical.games;
in
{
  imports = [ ./heroic.nix ./minecraft.nix ./mangohud.nix ];

  options = {
    custom.applications.graphical.games = {
      enable = lib.mkEnableOption "Enable default game launchers";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.applications.graphical.games = {
      heroic.enable = true;
      minecraft.enable = true;
      mangohud.enable = true;
    };
  };
}
