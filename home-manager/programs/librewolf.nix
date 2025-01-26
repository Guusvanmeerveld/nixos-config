{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.programs.librewolf;
in {
  options = {
    custom.programs.librewolf = {
      enable = lib.mkEnableOption "Enable Librewolf browser";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.librewolf = {
      enable = true;
      package = pkgs.librewolf;

      settings = {
        "webgl.disabled" = false;
        "privacy.clearOnShutdown.history" = false;
        "privacy.clearOnShutdown.downloads" = false;
        "browser.toolbars.bookmarks.visibility" = "never";
      };
    };
  };
}
