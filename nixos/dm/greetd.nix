{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.dm.greetd;
  outputsCfg = config.custom.hardware.video.outputs;

  gtkGreetStyle = pkgs.writeText "gtkgreet-css" ''
    window {
      background-image: url("${cfg.backgroundImage}");
      background-size: cover;
      background-position: center;
    }

    box#body {
      background-color: rgba(50, 50, 50, 0.5);
      border-radius: 10px;
      padding: 50px;
    }
  '';

  greeter = "${lib.getExe pkgs.greetd.gtkgreet} -l";

  swayConfig = pkgs.writeText "greetd-sway-config" ''
    exec "${greeter}; swaymsg exit"

    bindsym Mod4+shift+e exec swaynag \
      -t warning \
      -m 'What do you want to do?' \
      -b 'Poweroff' 'systemctl poweroff' \
      -b 'Reboot' 'systemctl reboot'

    ${
      lib.concatStringsSep "\n" (
        map ({
          name,
          value,
        }: ''
          output ${name} {
            mode ${value.resolution}@${toString value.refreshRate}Hz
            bg ${value.background}
            pos ${toString value.position.x} ${toString value.position.y}
            transform ${toString value.transform}
          }
        '')
        (lib.attrsToList outputsCfg)
      )
    }
  '';

  sway = "${lib.getExe pkgs.sway} --config ${swayConfig}";
in {
  options = {
    custom.dm.greetd = {
      enable = lib.mkEnableOption "Enable greetd display manager";
    };
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;

      settings = {
        default_session = {
          command = sway;
        };
      };
    };

    environment.etc."greetd/environments".text = ''
      ${config.custom.wm.default.path}
    '';
  };
}
