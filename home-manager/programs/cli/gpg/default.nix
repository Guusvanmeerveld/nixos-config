{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.cli.gpg;
in {
  options = {
    custom.programs.cli.gpg = {
      enable = lib.mkEnableOption "Enable GnuPG";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.gpg = {
      enable = true;

      mutableKeys = false;
      mutableTrust = false;

      publicKeys = [
        {
          source = ./personal.asc;
          trust = "full";
        }
      ];
    };

    home.packages = [pkgs.gcr];

    services.gpg-agent = {
      enable = true;

      pinentryPackage = pkgs.pinentry-gnome3;
    };
  };
}
