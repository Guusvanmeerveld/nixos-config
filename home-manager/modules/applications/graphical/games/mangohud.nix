{ lib, config, pkgs, ... }:
let cfg = config.custom.applications.graphical.games.mangohud; in
{
  options = {
    custom.applications.graphical.games.mangohud = {
      enable = lib.mkEnableOption "Enable MangoHud game overlay";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.mangohud = {
      enable = true;

      settings = {
        # GPU
        gpu_stats = true;
        vram = true;
        gpu_temp = true;

        # CPU
        cpu_stats = true;
        cpu_temp = true;

        ram = true;

        fps = true;
        frametime = true;

        throttling_status = true;

        text_outline = true;
      };
    };
  };
}

