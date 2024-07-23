{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.services.minecraft;
in {
  options = {
    custom.applications.services.minecraft = {
      enable = lib.mkEnableOption "Enable minecraft server service";

      openFirewall = lib.mkEnableOption "Enable default minecraft server port";
      openGeyserFirewall = lib.mkEnableOption "Enable default geyser plugin port";
      openVoiceChatFirewall = lib.mkEnableOption "Enable default voice chat plugin port";
    };
  };

  config = {
    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall 25565;
    networking.firewall.allowedUDPPorts = lib.optional cfg.openGeyserFirewall 19132 ++ lib.optional cfg.openVoiceChatFirewall 24454;
  };
}
