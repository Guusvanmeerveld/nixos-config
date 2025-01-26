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

      lfs.enable = true;

      difftastic.enable = true;
    };
  };
}
