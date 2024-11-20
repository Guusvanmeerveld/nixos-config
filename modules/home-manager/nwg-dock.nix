{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.services.nwg-dock;
in {
  options = {
    services.nwg-dock = {
      enable = lib.mkEnableOption "Enable NWG Dock";

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.custom.nwg-dock;
      };

      settings = {
        autohide = lib.mkEnableOption "Show dock when hotspot hovered, close when left or a button clicked";
        debug = lib.mkEnableOption "Turn on debug messages";
        noLauncher = lib.mkEnableOption "Don't show the launcher button";
        noWorkspaceSwitcher = lib.mkEnableOption "Don't show the workspace switcher";
        resident = lib.mkEnableOption "Leave the program resident, but w/o hotspot";
        exclusiveZone = lib.mkEnableOption "Set eXclusive zone: move other windows aside; overrides the layer argument";

        layer = lib.mkOption {
          type = lib.types.enum ["overlay" "top" "bottom"];
          description = "The layer to show the dock on";
          default = "overlay";
        };

        margin = {
          bottom = lib.mkOption {
            type = lib.types.int;
            default = 0;
          };

          left = lib.mkOption {
            type = lib.types.int;
            default = 0;
          };

          top = lib.mkOption {
            type = lib.types.int;
            default = 0;
          };

          right = lib.mkOption {
            type = lib.types.int;
            default = 0;
          };
        };

        iconSize = lib.mkOption {
          type = lib.types.int;
          default = 48;
        };

        position = lib.mkOption {
          type = lib.types.enum ["bottom" "top" "left"];
          description = "The position of the dock";
          default = "bottom";
        };

        output = lib.mkOption {
          type = lib.types.str;
          description = "Name of output to display the dock on";
          default = "";
        };

        style = lib.mkOption {
          type = lib.types.lines;
          description = ''
            CSS styles to apply.
            Example: https://github.com/nwg-piotr/nwg-dock/blob/main/config/style.css
          '';
          default = '''';
        };

        hotspot = {
          delay = lib.mkOption {
            type = lib.types.int;
            description = ''
              Hotspot Delay [ms]; the smaller, the faster mouse pointer needs to enter hotspot for the dock to appear;
              set 0 to disable
            '';
            default = 500;
          };

          style = lib.mkOption {
            type = lib.types.lines;
            description = ''
              CSS styles to apply.
              Example: https://github.com/nwg-piotr/nwg-dock/blob/main/config/hotspot.css
            '';
            default = '''';
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [nwg-dock];

    xdg.configFile = {
      "nwg-dock/style.css" = {
        text = cfg.settings.style;
      };

      "nwg-dock/hotspot.css" = {
        text = cfg.settings.hotspot.style;
      };
    };

    systemd.user.services.nwg-dock = {
      Unit = {
        Description = "GTK3-based dock for sway";
        Documentation = "https://github.com/nwg-piotr/nwg-dock";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session-pre.target"];

        ConditionEnvironment = "WAYLAND_DISPLAY";
      };

      Service = {
        Type = "simple";
        ExecStart = ''
          ${lib.getExe cfg.package} \
            ${lib.optionalString cfg.settings.autohide "-d"} \
            ${lib.optionalString cfg.settings.debug "-debug"} \
            ${lib.optionalString (cfg.settings.output != "") "-o ${cfg.settings.output}"} \
            ${lib.optionalString cfg.settings.noLauncher "-nolauncher"} \
            ${lib.optionalString cfg.settings.noWorkspaceSwitcher "-nows"} \
            -p ${cfg.settings.position} \
            -hd ${toString cfg.settings.hotspot.delay} \
            -mb ${toString cfg.settings.margin.bottom} \
            -ml ${toString cfg.settings.margin.left} \
            -mr ${toString cfg.settings.margin.right} \
            -mt ${toString cfg.settings.margin.top} \
            -i ${toString cfg.settings.iconSize} \
            -l ${cfg.settings.layer} \
        '';
        Restart = "on-failure";
      };

      Install.WantedBy = ["sway-session.target"];
    };
  };
}
