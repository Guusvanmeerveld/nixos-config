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
    ./jellyfin-client.nix
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
    ./feishin.nix
  ];

  options = {
    custom.programs = {
      default.enable = lib.mkEnableOption "Enable default applications";
    };
  };

  config = lib.mkIf cfg.default.enable {
    custom.programs = {
      evince.enable = lib.mkDefault true;
      librewolf.enable = lib.mkDefault true;
      kitty.enable = lib.mkDefault true;
      nautilus.enable = lib.mkDefault true;
      feishin.enable = lib.mkDefault true;
      thunderbird.enable = lib.mkDefault true;
      mpv.enable = lib.mkDefault true;
      loupe.enable = lib.mkDefault true;
      file-roller.enable = lib.mkDefault true;
      gnome-calculator.enable = lib.mkDefault true;
      freetube.enable = lib.mkDefault true;
      missioncenter.enable = lib.mkDefault true;
      cheese.enable = lib.mkDefault true;
      jellyfin-client.enable = lib.mkDefault true;
    };
  };
}
