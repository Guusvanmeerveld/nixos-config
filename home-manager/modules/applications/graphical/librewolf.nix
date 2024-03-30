{ lib, config, pkgs, ... }:
let cfg = config.custom.applications.graphical.librewolf; in
{
  options = {
    custom.applications.graphical.librewolf = {
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
