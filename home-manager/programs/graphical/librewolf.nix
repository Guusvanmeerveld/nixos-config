{ config, pkgs, ... }:


{
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
}
