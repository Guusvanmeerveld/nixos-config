{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs;
  settingsFormat = pkgs.formats.json {};
in {
  imports = [
    ./development
    ./office
    ./games
    ./theming
    ./messaging
    ./cli
    ./rofi.nix
    ./librewolf.nix
    ./evince.nix
    ./firefox.nix
    ./kitty.nix
    ./flameshot.nix
    ./thunar.nix
    ./spotify.nix
    ./jellyfin.nix
    ./thunderbird.nix
    ./grim.nix
    ./mpv.nix
    ./loupe.nix
    ./file-roller.nix
    ./openshot.nix
    ./gnome-calculator.nix
    ./ario.nix
    ./cantata.nix
    ./qbittorrent.nix
    ./nautilus.nix
    ./parsec.nix
    ./freetube.nix
    ./eduvpn.nix
  ];

  options = {
    custom.programs = {
      default.enable = lib.mkEnableOption "Enable default applications";

      defaultApplications = lib.mkOption {
        default = {};

        type = lib.types.attrsOf (lib.types.submodule ({...}: {
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
    custom.programs = {
      evince.enable = true;
      firefox.enable = true;
      kitty.enable = true;
      grim.enable = true;
      nautilus.enable = true;
      spotify.enable = true;
      thunderbird.enable = true;
      mpv.enable = true;
      loupe.enable = true;
      file-roller.enable = true;
      gnome-calculator.enable = true;
      freetube.enable = true;
    };
  };
}
