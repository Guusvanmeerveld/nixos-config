{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.dm.greetd;

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

  greeter = "${lib.getExe pkgs.greetd.gtkgreet} -l -s ${gtkGreetStyle}";

  # swayConfig = pkgs.writeText "greetd-sway-config" ''
  #   exec "${greeter}; swaymsg exit"

  #   bindsym Mod4+shift+e exec swaynag \
  #     -t warning \
  #     -m 'What do you want to do?' \
  #     -b 'Poweroff' 'systemctl poweroff' \
  #     -b 'Reboot' 'systemctl reboot'
  # '';

  # sway = "${lib.getExe pkgs.sway} --config ${swayConfig}";

  cage = "${lib.getExe pkgs.cage} -s -- ${greeter}";
in {
  options = {
    custom.dm.greetd = {
      enable = lib.mkEnableOption "Enable greetd display manager";

      backgroundImage = lib.mkOption {
        type = lib.types.path;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;

      settings = {
        default_session = {
          command = cage;
        };
      };
    };

    environment.etc."greetd/environments".text = ''
      ${config.custom.wm.default.path}
    '';
  };
}
