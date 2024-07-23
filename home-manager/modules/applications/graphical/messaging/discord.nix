{
  outputs,
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.graphical.messaging.discord;
in {
  imports = [outputs.homeManagerModules.armcord];

  options = {
    custom.applications.graphical.messaging.discord = {
      enable = lib.mkEnableOption "Enable Discord client";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.armcord = {
      enable = true;

      settings = {
        windowStyle = "native";
        channel = "stable";
        mods = "vencord";
        performanceMode = "none";
        trayIcon = "default";
        armcordCSP = true;
        spellcheck = true;
        useLegacyCapturer = false;
        minimizeToTray = false;
        tray = false;
        doneSetup = true;
        skipSplash = true;
      };
    };
  };
}
