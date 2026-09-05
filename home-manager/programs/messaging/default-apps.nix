{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.messaging.default-apps;
in {
  options.custom.programs.messaging.default-apps.enable = lib.mkEnableOption "Enable default messaging applications";

  config = lib.mkIf cfg.enable {
    custom.programs.messaging = {
      signal.enable = lib.mkDefault true;
      vesktop.enable = lib.mkDefault true;
      mumble.enable = lib.mkDefault true;
    };
  };
}
