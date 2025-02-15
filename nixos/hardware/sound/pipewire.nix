{
  inputs,
  lib,
  config,
  ...
}: let
  cfg = config.custom.hardware.sound.pipewire;
in {
  imports = [
    # Import low latency module
    inputs.nix-gaming.nixosModules.pipewireLowLatency
  ];

  options = {
    custom.hardware.sound.pipewire = {
      enable = lib.mkEnableOption "Enable pipewire sound engine";
    };
  };

  config = lib.mkIf cfg.enable {
    # make pipewire realtime-capable
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;

      alsa = {
        enable = true;
        support32Bit = true;
      };

      jack.enable = true;
      pulse.enable = true;

      lowLatency = {
        enable = true;
      };

      # https://gitlab.freedesktop.org/pipewire/pipewire/-/issues/2669
      wireplumber.extraConfig = {
        "10-disable-camera" = {
          "wireplumber.profiles" = {
            main = {
              "monitor.libcamera" = "disabled";
            };
          };
        };
      };
    };
  };
}
