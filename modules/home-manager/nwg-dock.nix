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

        pinnedApps = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = "A list of items to be pinned on the dock";
          default = [];
        };

        layer = lib.mkOption {
          type = lib.types.enum ["overlay" "top" "bottom"];
          description = "The layer to show the dock on";
          default = "overlay";
        };

        alignment = lib.mkOption {
          type = lib.types.enum ["start" "center" "end"];
          description = "Alignment in full width/height";
          default = "center";
        };

        position = lib.mkOption {
          type = lib.types.enum ["bottom" "top" "left"];
          description = "The position of the dock";
          default = "bottom";
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
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [nwg-dock];

    home.file.".cache/nwg-dock-pinned" = {
      text = lib.concatStringsSep "\n" cfg.settings.pinnedApps;
    };

    xdg.configFile = {
      "nwg-dock/style.css" = {
        text = cfg.settings.style;
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
        Restart = "on-failure";

        # This is a hacky work around to make sure the users PATH variable is loaded for the application.
        # See: https://discourse.nixos.org/t/systemd-user-units-and-no-such-path/8399/
        ExecStart = ''
          ${lib.getExe pkgs.bash} -lc ${
            lib.getExe (pkgs.writeShellApplication {
              name = "start-nwg-dock";

              text = ''
                ${lib.getExe cfg.package} \
                 ${lib.optionalString cfg.settings.autohide "-d"} \
                 ${lib.optionalString cfg.settings.debug "-debug"} \
                 ${lib.optionalString (cfg.settings.output != "") "-o ${cfg.settings.output}"} \
                 ${lib.optionalString cfg.settings.noLauncher "-nolauncher"} \
                 ${lib.optionalString cfg.settings.noWorkspaceSwitcher "-nows"} \
                 -a ${cfg.settings.alignment} \
                 -p ${cfg.settings.position} \
                 -hd ${toString cfg.settings.hotspot.delay} \
                 -mb ${toString cfg.settings.margin.bottom} \
                 -ml ${toString cfg.settings.margin.left} \
                 -mr ${toString cfg.settings.margin.right} \
                 -mt ${toString cfg.settings.margin.top} \
                 -i ${toString cfg.settings.iconSize} \
                 -l ${cfg.settings.layer} \'';
            })
          }
        '';
      };

      Install.WantedBy = ["sway-session.target"];
    };
  };
}
