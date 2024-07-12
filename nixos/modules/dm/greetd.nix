{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.dm.greetd;
  cage = "${pkgs.cage}/bin/cage";
  gtkgreet = "${pkgs.greetd.gtkgreet}/bin/gtkgreet";
in {
  options = {
    custom.dm.greetd = {
      enable = lib.mkEnableOption "Enable greetd display manager";

      # background-image = lib.mkOption {
      #   type = lib.types.orNull lib.types.path;
      # };
    };
  };

  config = lib.mkIf cfg.enable {
    services.greetd = {
      enable = true;

      settings = {
        default_session = {
          command = "${cage} -s -- ${gtkgreet}";
        };
      };
    };

    environment.etc."greetd/environments".text = ''
      ${config.custom.wm.default.path}
    '';
  };
}
