{ lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.loader = {
    efi = {
        canTouchEfiVariables = true;
 	      efiSysMountPoint = "/boot/efi";
    };
    grub = {
    	efiSupport = true;
    	device = "nodev";
    	configurationLimit = 2;
    };
  };
  fileSystems."/boot/efi" = { device = "/dev/disk/by-uuid/21F4-B0A5"; fsType = "vfat"; };
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" ];
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";  
}
