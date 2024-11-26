{
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.wm.docks.nwg-dock;

  fromHex = hex: (builtins.fromTOML "a = 0x${hex}").a;

  makeTransparent = hex: transparancy: let
    r = fromHex (lib.substring 1 2 hex);
    g = fromHex (lib.substring 3 2 hex);
    b = fromHex (lib.substring 5 2 hex);
    a = transparancy; # Set your desired alpha value here (0.0 to 1.0)
  in "rgba(${toString r}, ${toString g}, ${toString b}, ${toString a})";
in {
  imports = [outputs.homeManagerModules.nwg-dock];

  options = {
    custom.wm.docks.nwg-dock = {
      enable = lib.mkEnableOption "Enable NWG Dock";

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.nwg-dock;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.nwg-dock = {
      enable = true;

      settings = {
        margin = {
          bottom = 50;
        };

        layer = "bottom";
        position = "bottom";
        noLauncher = true;
        noWorkspaceSwitcher = true;

        pinnedApps = [
          "codium-url-handler"
          "firefox"
          "vesktop"
          "steam"
          "kitty"
          "Element"
          "heroic"
        ];

        style = ''
          window {
            background-color: ${makeTransparent "#${config.colorScheme.palette.base00}" 0.8};
          	border-radius: 15px;
          	border-style: none;
          	border-width: 1px;
          }

          #box {
            /* Define attributes of the box surrounding icons here */
            padding: 10px
          }

          button, image {
          	background: none;
          	box-shadow: none;
          	color: #999;
          }

          button {
          	/*padding-left: 4px;
          	padding-right: 4px;*/
          	padding: 4px;
          	margin-left: 4px;
          	margin-right: 4px;
          	color: #eee;
            font-size: 12px;
            border-width: 1px;
          	border-radius: 10px;
            border-color: rgba (0, 0, 0, 0);
            border-style: solid;
          }

          button:hover {
          	background-color: rgba(255, 255, 255, 0.15);
          	border-radius: 10px;
            border-width: 1px;
            border-style: solid;
            border-color: rgba(255, 255, 255, 0.25);
          }

          button:focus {
          	box-shadow: 0 0 2px;
          }
        '';
      };
    };
  };
}
