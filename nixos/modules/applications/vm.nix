{ config, lib, pkgs, ... }:
let cfg = config.custom.applications.vm; in
{
  options = {
    custom.applications.vm = {
      enable = lib.mkEnableOption "Enable virtualization software";
      graphical = lib.mkEnableOption "Enable graphical interface";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ qemu libvirt virt-manager ];
  };

}
