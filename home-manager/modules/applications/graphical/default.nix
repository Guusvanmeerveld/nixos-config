{ lib, config, ... }:
let cfg = config.custom.applications.graphical; in
{
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
  ];

  options = {
    custom.applications.graphical = {
      enable = lib.mkEnableOption "Enable default applications";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.applications.graphical = {
      evince.enable = true;
      firefox.enable = true;
      kitty.enable = true;
      kdeconnect.enable = true;
      flameshot.enable = true;
      thunar.enable = true;
      spotify.enable = true;
    };
  };
}