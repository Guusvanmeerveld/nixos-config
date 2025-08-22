{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.wm.wayland.sway.osd;

  package = pkgs.swayosd;

  swayosd-client = lib.getExe' package "swayosd-client";
in {
  options = {
    custom.wm.wayland.sway.osd = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = config.custom.wm.wayland.sway.enable;
        description = "Enable sway osd";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    custom.wm.applications = [
      {
        keybind = "XF86AudioRaiseVolume";
        executable = "${swayosd-client} --output-volume +5";
      }
      {
        keybind = "XF86AudioLowerVolume";
        executable = "${swayosd-client} --output-volume -5";
      }
      {
        keybind = "XF86AudioMute";
        executable = "${swayosd-client} --output-volume mute-toggle";
      }
      {
        keybind = "XF86AudioMicMute";
        executable = "${swayosd-client} --input-volume mute-toggle";
      }
      {
        keybind = "XF86MonBrightnessUp"; # pragma: allowlist secret
        executable = "${swayosd-client} --brightness +5";
      }
      {
        keybind = "XF86MonBrightnessDown";
        executable = "${swayosd-client} --brightness -5";
      }
      {
        keybind = "XF86AudioPlay";
        executable = "${swayosd-client} --playerctl play";
      }
      {
        keybind = "XF86AudioStop";
        executable = "${swayosd-client} --playerctl pause";
      }
      {
        keybind = "XF86AudioPause";
        executable = "${swayosd-client} --playerctl play-pause";
      }
      {
        keybind = "XF86AudioNext";
        executable = "${swayosd-client} --playerctl next";
      }
      {
        keybind = "XF86AudioPrev";
        executable = "${swayosd-client} --playerctl previous";
      }
    ];

    services.swayosd = {
      enable = true;
    };
  };
}
