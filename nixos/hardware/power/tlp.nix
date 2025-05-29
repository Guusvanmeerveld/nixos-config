{
  config,
  lib,
  ...
}: let
  cfg = config.custom.hardware.power.tlp;
in {
  options = {
    custom.hardware.power.tlp.enable = lib.mkEnableOption "Enable TLP laptop power management";
  };

  config = lib.mkIf cfg.enable {
    services.tlp = {
      enable = true;

      settings = {
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_SCALING_GOVERNOR_ON_AC = "performance";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 75;

        #Optional helps save long term battery health
        START_CHARGE_THRESH_BAT0 = 40; # 40 and below it starts to charge
        STOP_CHARGE_THRESH_BAT0 = 1; # Enable battery conservation mode
      };
    };
  };
}
