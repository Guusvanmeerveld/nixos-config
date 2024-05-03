{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.custom.applications.graphical.spotify;
  spicePkgs = inputs.spicetify-nix.packages.${pkgs.system}.default;
in {
  imports = [inputs.spicetify-nix.homeManagerModule];

  options = {
    custom.applications.graphical.spotify = {
      enable = lib.mkEnableOption "Enable Spotify music application";
    };
  };

  config = lib.mkIf cfg.enable {
    # nixpkgs.config.allowUnfreePredicate = pkg:
    #   builtins.elem (lib.getName pkg) [
    #     "spotify"
    #   ];

    programs.spicetify = {
      enable = true;

      windowManagerPatch = true;

      colorScheme = "custom";
      customColorScheme = {
        text = config.colorScheme.palette.base07;
        subtext = config.colorScheme.palette.base06;
        alt-text = config.colorScheme.palette.base06;
        main = config.colorScheme.palette.base01;
        sidebar = config.colorScheme.palette.base00;
        player = config.colorScheme.palette.base00;
        # player-bar-shadow = "040508";
        # player-bar-bg = "313131";
        card = config.colorScheme.palette.base00;
        shadow = config.colorScheme.palette.base01;
        selected-row = config.colorScheme.palette.base03;
        button = config.colorScheme.palette.base0F;
        button-active = config.colorScheme.palette.base0F;
        button-disabled = config.colorScheme.palette.base0C;
        tab-active = config.colorScheme.palette.base01;
        notification = config.colorScheme.palette.base0F;
        notification-error = config.colorScheme.palette.base08;
        notif-bubble-info = config.colorScheme.palette.base0C;
        notif-bubble-error = config.colorScheme.palette.base08;
        misc = config.colorScheme.palette.base06;
        not-selected = config.colorScheme.palette.base07;
        accent = config.colorScheme.palette.base0B;
        layer-shadow = config.colorScheme.palette.base00;
        contour = config.colorScheme.palette.base02;
        dark-border = config.colorScheme.palette.base00;
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
