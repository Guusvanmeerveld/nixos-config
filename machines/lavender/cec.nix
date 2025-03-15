{pkgs, ...}: {
  # https://wiki.nixos.org/wiki/NixOS_on_ARM/Raspberry_Pi_4#HDMI-CEC
  nixpkgs.overlays = [
    (_self: super: {libcec = super.libcec.override {withLibraspberrypi = true;};})
  ];

  environment.systemPackages = with pkgs; [
    libcec
  ];
}
