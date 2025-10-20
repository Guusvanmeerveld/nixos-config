{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.cli.rbw;
in {
  options = let
    inherit (lib) mkOption types;
  in {
    custom.programs.cli.rbw = {
      enable = lib.mkEnableOption "Enable rbw bitwarden client";

      bitwardenUrl = mkOption {
        type = types.str;
        default = "https://bitwarden.sun";

        description = "Url to the remote bitwarden server";
      };
    };
  };

  config = let
    inherit (lib) mkIf;
  in
    mkIf cfg.enable {
      programs.rbw = {
        enable = true;

        settings = {
          email = "mail@guusvanmeerveld.dev";
          lock_timeout = 300;
          base_url = cfg.bitwardenUrl;

          pinentry = pkgs.pinentry-gnome3;
        };
      };
    };
}
