{ lib, config, pkgs, ... }:
let cfg = config.custom.applications.graphical.games.heroic; in
{
  options = {
    custom.applications.graphical.games.heroic = {
      enable = lib.mkEnableOption "Enable Heroic games launcher";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ heroic gamemode ];

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

