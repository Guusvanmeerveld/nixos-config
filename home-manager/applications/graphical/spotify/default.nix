{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.graphical.spotify;
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in {
  imports = [inputs.spicetify-nix.homeManagerModules.default];

  options = {
    custom.applications.graphical.spotify = {
      enable = lib.mkEnableOption "Enable Spotify music application";
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.desktopEntries = {
      spotify = {
        name = "Spotify";
        genericName = "Music Player";
        icon = toString ./spotify.svg;
        exec = "spotify";
        comment = "Play music from spotifys library";
        terminal = false;
        categories = ["Application" "Network" "Audio"];
      };
    };

    programs.spicetify = {
      enable = true;

      windowManagerPatch = true;

      spicetifyPackage = pkgs.unstable.spicetify-cli;

      colorScheme = "custom";
      customColorScheme = let
        bg-color = config.colorScheme.palette.base00;
        alt-bg-color = config.colorScheme.palette.base01;

        font-color = config.colorScheme.palette.base06;
        alt-font-color = config.colorScheme.palette.base05;
        # accent-color = ;
      in {
        text = font-color;
        subtext = alt-font-color;
        alt-text = alt-font-color;
        main = alt-bg-color;
        sidebar = bg-color;
        player = bg-color;
        # player-bar-shadow = "040508";
        # player-bar-bg = "313131";
        card = bg-color;
        shadow = alt-bg-color;
        selected-row = config.colorScheme.palette.base03;
        button = config.colorScheme.palette.base0F;
        button-active = config.colorScheme.palette.base0F;
        button-disabled = config.colorScheme.palette.base0C;
        tab-active = alt-bg-color;
        notification = config.colorScheme.palette.base0F;
        notification-error = config.colorScheme.palette.base08;
        notif-bubble-info = config.colorScheme.palette.base0C;
        notif-bubble-error = config.colorScheme.palette.base08;
        misc = alt-font-color;
        not-selected = font-color;
        accent = config.colorScheme.palette.base0B;
        layer-shadow = bg-color;
        contour = config.colorScheme.palette.base02;
        dark-border = bg-color;
        light-border = config.colorScheme.palette.base03;
      };

      enabledExtensions = with spicePkgs.extensions; [
        fullAppDisplay
        shuffle # shuffle+ (special characters are sanitized out of ext names)
        hidePodcasts
        keyboardShortcut
        powerBar
        seekSong
        fullAlbumDate
      ];
    };
  };
}
