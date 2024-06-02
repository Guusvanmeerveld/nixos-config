{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.graphical.messaging;
in {
  imports = [./schildichat.nix ./discord.nix ./element.nix];

  options = {
    custom.applications.graphical.messaging = {
      enable = lib.mkEnableOption "Enable default messaging applications";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.applications.graphical.messaging = {
      element.enable = true;
      discord.enable = true;
    };
  };
}
