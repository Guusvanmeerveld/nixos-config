{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.cli.git;
in {
  options = {
    custom.programs.cli.git = {
      enable = lib.mkEnableOption "Enable Git version control manager client";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = "Guus van Meerveld";
      userEmail = "mail@guusvanmeerveld.dev";

      signing = {
        # Set to null to let GnuPG decide what signing key to use depending on commit's author.
        key = null;
        signByDefault = lib.mkDefault config.programs.gpg.enable;
      };

      lfs.enable = true;
      maintenance.enable = true;
      difftastic.enable = true;
    };
  };
}
