{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.games;
in {
  imports = [./heroic.nix ./minecraft.nix ./mangohud.nix ./scarab.nix ./emulators];

  options = {
    custom.programs.games = {
      enable = lib.mkEnableOption "Enable default game launchers";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.programs.games = {
      heroic.enable = true;
      minecraft.enable = true;
      mangohud.enable = true;
    };
  };
}
