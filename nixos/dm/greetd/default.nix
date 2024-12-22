{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.dm.greetd;
  outputsCfg = config.custom.hardware.video.outputs;

  defaultEnvironment = config.custom.wm.default.path;

  gtkgreet = import ./gtkgreet.nix {inherit lib pkgs;};
  tuigreet = import ./tuigreet.nix {inherit lib pkgs;};

  greeters = {
    "gtkgreet" = gtkgreet.executable;
    "tuigreet" = tuigreet.executable {cmd = defaultEnvironment;};
  };

  currentGreeterExecutable = builtins.getAttr cfg.greeter greeters;

  greetersNeedGraphical = {
    "gtkgreet" = true;
    "tuigreet" = false;
  };

  swayConfig = pkgs.writeText "greetd-sway-config" ''
    exec "${currentGreeterExecutable}; swaymsg exit"

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

      greeter = lib.mkOption {
        type = lib.types.enum ["gtkgreet" "tuigreet"];
        default = "gtkgreet";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;

      settings = {
        default_session = let
          needsGraphical = builtins.getAttr cfg.greeter greetersNeedGraphical;
        in {
          command =
            if needsGraphical
            then sway
            else currentGreeterExecutable;
        };
      };
    };

    environment.etc."greetd/environments".text = ''
      ${defaultEnvironment}
    '';
  };
}
