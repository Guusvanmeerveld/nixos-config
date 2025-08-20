{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.services.playerctld;
in {
  options = {
    custom.services.playerctld = {
      enable = lib.mkEnableOption "Enable playerctld";
    };
  };

  config = lib.mkIf cfg.enable {
    services.playerctld = {
      enable = true;
    };

    custom.wm.applications = let
      playerctl = lib.getExe pkgs.playerctl;
    in [
      {
        keybind = "XF86AudioPlay";
        executable = "${playerctl} play";
      }
      {
        keybind = "XF86AudioStop";
        executable = "${playerctl} pause";
      }
      {
        keybind = "XF86AudioPause";
        executable = "${playerctl} play-pause";
      }
      {
        keybind = "XF86AudioNext";
        executable = "${playerctl} next";
      }
      {
        keybind = "XF86AudioPrev";
        executable = "${playerctl} previous";
      }
      # {
      #   # XF86AudioPlayPause: xmodmap -pke | grep XF86AudioPlay
      #   # https://github.com/swaywm/sway/issues/4783
      #   keybind = "172";
      #   executable = " ${playerctl} play-pause";
      # }
    ];
  };
}
