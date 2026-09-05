{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs;
in {
  options.custom.programs.default-apps.enable = lib.mkEnableOption "Enable default applications";

  config = lib.mkIf cfg.default-apps.enable {
    custom.programs = {
      evince.enable = lib.mkDefault true;
      librewolf.enable = lib.mkDefault true;
      kitty.enable = lib.mkDefault true;
      nautilus.enable = lib.mkDefault true;
      feishin.enable = lib.mkDefault true;
      thunderbird.enable = lib.mkDefault true;
      mpv.enable = lib.mkDefault true;
      loupe.enable = lib.mkDefault true;
      file-roller.enable = lib.mkDefault true;
      gnome-calculator.enable = lib.mkDefault true;
      freetube.enable = lib.mkDefault true;
      missioncenter.enable = lib.mkDefault true;
      cheese.enable = lib.mkDefault true;
      jellyfin-client.enable = lib.mkDefault true;
      eduvpn.enable = lib.mkDefault true;
    };
  };
}
