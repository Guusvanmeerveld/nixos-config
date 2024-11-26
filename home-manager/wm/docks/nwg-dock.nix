{
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.wm.docks.nwg-dock;
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
            background-color: ${pkgs.custom.utils.makeTransparent "#${config.colorScheme.palette.base00}" 0.8};
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
