{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.shell.git;
in {
  options = {
    custom.applications.shell.git = {
      enable = lib.mkEnableOption "Enable Git version control manager client";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = "Guus van Meerveld";
      userEmail = "mail@guusvanmeerveld.dev";

      lfs.enable = true;
    };
  };
}
