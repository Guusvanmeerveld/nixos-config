{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.wm.wayland.cliphist;

  package = pkgs.writeShellApplication {
    name = "cliphist-menu";

    runtimeInputs = with pkgs; [nwg-clipman wl-clipboard];

    text = ''
      nwg-clipman
    '';
  };
in {
  options = {
    custom.wm.wayland.cliphist.enable = lib.mkEnableOption "Enable cliphist";
  };

  config = lib.mkIf cfg.enable {
    custom.wm.applications = [
      {
        inherit package;
        keybind = "Ctrl+Alt+v";
      }
    ];

    home.packages = [package];

    services.cliphist.enable = true;
  };
}
