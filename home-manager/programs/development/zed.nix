{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.development.zed;
in {
  options = {
    custom.programs.development.zed = {
      enable = lib.mkEnableOption "Enable Zed development IDE";
    };
  };

  config = lib.mkIf cfg.enable {
    custom.wm.applications = [
      {
        inherit (config.programs.zed-editor) package;
        appId = "dev.zed.Zed";
        keybind = "$mod+g";
        workspace = 4;
      }
    ];

    programs.zed-editor = {
      enable = true;

      extraPackages = with pkgs; [nil rust-analyzer];

      extensions = ["nix" "java" "one-dark-pro"];

      userSettings = {
        theme = "one-dark-pro";

        features = {
          edit_prediction_provider = "zed";
        };

        telemetry = {
          metrics = false;
        };

        vim_mode = false;

        ui_font_size = 16;

        buffer_font_family = config.custom.programs.theming.font.monospace.name;
        buffer_font_size = 16;
      };
    };
  };
}
