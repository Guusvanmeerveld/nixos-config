{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.qemu;
in {
  options = {
    custom.applications.qemu = {
      enable = lib.mkEnableOption "Enable virtualization software";
      graphical = lib.mkEnableOption "Enable graphical interface";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = cfg.graphical;

    environment.systemPackages = with pkgs; [
      qemu

      (pkgs.writeShellScriptBin "qemu-system-x86_64-uefi" ''
        qemu-system-x86_64 \
          -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
          "$@"
      '')
    ];
  };
}
