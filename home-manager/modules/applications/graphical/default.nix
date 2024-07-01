{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical;
  settingsFormat = pkgs.formats.json {};
in {
  imports = [
    ./development
    ./office
    ./games
    ./messaging
    ./rofi.nix
    ./librewolf.nix
    ./evince.nix
    ./firefox.nix
    ./kitty.nix
    ./kdeconnect.nix
    ./flameshot.nix
    ./thunar.nix
    ./spotify.nix
    ./jellyfin.nix
    ./gtk.nix
    ./thunderbird.nix
    ./font.nix
  ];

  options = {
    custom.applications.graphical = {
      default.enable = lib.mkEnableOption "Enable default applications";

      defaultApplications = lib.mkOption {
        default = {};

        type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
          freeformType = settingsFormat.type;

          options = {
            name = lib.mkOption {
              type = lib.types.str;
            };

            path = lib.mkOption {
              type = lib.types.str;
            };

            wm-class = lib.mkOption {
              type = lib.types.str;
            };
          };
        }));
      };
    };
  };

  config = lib.mkIf cfg.default.enable {
    custom.applications.graphical = {
      evince.enable = true;
      firefox.enable = true;
      kitty.enable = true;
      kdeconnect.enable = true;
      flameshot.enable = true;
      thunar.enable = true;
      spotify.enable = true;
      gtk.enable = true;
      thunderbird.enable = true;
    };
  };
}
