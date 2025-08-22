{
  lib,
  config,
  ...
}: let
  cfg = config.custom.wm.wayland.sway.idle;

  lockTimeout = 300;
  screenOffTimeout = lockTimeout + 60;
  suspendTimeout = screenOffTimeout + 300;
in {
  options = {
    custom.wm.wayland.sway.idle = with lib; {
      enable = mkOption {
        type = types.bool;
        default = config.custom.wm.wayland.sway.enable;
        description = "Enable swayidle";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.swayidle = {
      enable = true;

      timeouts = [
        {
          timeout = lockTimeout;
          command = config.custom.wm.lockscreens.default.executable;
        }
        {
          timeout = screenOffTimeout;
          command = ''swaymsg "output * dpms on'';
          resumeCommand = ''swaymsg "output * dpms on'';
        }
        {
          timeout = suspendTimeout;
          command = "systemctl suspend";
        }
      ];
    };
  };
}
