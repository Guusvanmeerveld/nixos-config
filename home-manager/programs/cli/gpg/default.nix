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

    services.gpg-agent = let
      ttl = 365 * 24 * 60 * 60;
    in {
      enable = true;

      defaultCacheTtl = ttl;
      maxCacheTtl = ttl;
      pinentry.package = pkgs.pinentry-gnome3;
    };
  };
}
