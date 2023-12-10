{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ qemu libvirt virt-manager ];
}
