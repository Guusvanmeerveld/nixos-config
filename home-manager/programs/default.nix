{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs;
in {
  imports = [
    ./development
    ./office
    ./games
    ./theming
    ./messaging
    ./cli
    ./librewolf
    ./evince.nix
    ./kitty.nix
    ./flameshot.nix
    ./thunar.nix
    ./spotify.nix
    ./jellyfin.nix
    ./thunderbird.nix
    ./wayland-screenshot.nix
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
    ./missioncenter.nix
    ./tidal.nix
    ./cheese.nix
    ./tauon.nix
  ];

  options = {
    custom.programs = {
      default.enable = lib.mkEnableOption "Enable default applications";
    };
  };

  config = lib.mkIf cfg.default.enable {
    custom.programs = {
      evince.enable = true;
      librewolf.enable = true;
      kitty.enable = true;
      nautilus.enable = true;
      tauon.enable = true;
      thunderbird.enable = true;
      mpv.enable = true;
      loupe.enable = true;
      file-roller.enable = true;
      gnome-calculator.enable = true;
      freetube.enable = true;
      missioncenter.enable = true;
      cheese.enable = true;
    };
  };
}
