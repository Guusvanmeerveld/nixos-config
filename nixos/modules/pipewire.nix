{
  lib,
  config,
  ...
}: let
  cfg = config.custom.pipewire;
in {
  options = {
    custom.pipewire = {
      enable = lib.mkEnableOption "Enable pipewire sound engine";
    };
  };

  config = lib.mkIf cfg.enable {
    services.pipewire = {
      enable = true;

      alsa = {
        enable = true;
        support32Bit = true;
      };

      jack.enable = true;
      pulse.enable = true;
    };
  };
}
