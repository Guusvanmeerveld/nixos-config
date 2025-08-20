{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    mergeAttrs
    mkOption
    ;

  cfg = config.programs.whatsie;

  iniFormat = pkgs.formats.ini {};

  settings =
    mergeAttrs {
      General = {
        app_install_time = 0;
        app_launched_count = 1;
        rated_already = true;
        appAutoLocking = false;
      };
    }
    cfg.settings;
in {
  options.programs.whatsie = {
    enable = mkEnableOption "Enable Whatsie whatsapp application";

    package = lib.mkPackageOption pkgs "whatsie" {};

    settings = mkOption {
      inherit (iniFormat) type;
      default = {};
      description = "Settings for application";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    xdg.configFile."org.keshavnrj.ubuntu/WhatSie.conf".source =
      iniFormat.generate "whatsie-settings" settings;
  };
}
