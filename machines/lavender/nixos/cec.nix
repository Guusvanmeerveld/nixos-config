{lib, config, pkgs, ...}: {
    # https://wiki.nixos.org/wiki/NixOS_on_ARM/Raspberry_Pi_4#HDMI-CEC

    nixpkgs.overlays = [
      (self: super: { libcec = super.libcec.override { withLibraspberrypi = true; }; })
    ];

    environment.systemPackages = with pkgs; [
        libcec
    ];

    services.udev.extraRules = ''
        # allow access to raspi cec device for video group (and optionally register it as a systemd device, used below)
        KERNEL=="vchiq", GROUP="video", MODE="0660", TAG+="systemd", ENV{SYSTEMD_ALIAS}="/dev/vchiq"
    '';
}