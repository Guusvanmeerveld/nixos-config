{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.virtualisation.qemu;
in {
  options = {
    custom.virtualisation.qemu = {
      enable = lib.mkEnableOption "Enable virtualisation software";
      graphical = lib.mkEnableOption "Enable graphical interface";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd.enable = true;

    programs.virt-manager.enable = lib.mkDefault cfg.graphical;

    environment.systemPackages = with pkgs; [
      qemu
    ];
  };
}
