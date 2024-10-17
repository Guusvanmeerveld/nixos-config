{
  outputs,
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.graphical.messaging.armcord;
in {
  imports = [outputs.homeManagerModules.armcord];

  options = {
    custom.applications.graphical.messaging.armcord = {
      enable = lib.mkEnableOption "Enable Armcord Discord client";
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
