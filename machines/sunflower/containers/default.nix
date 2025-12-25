{
  networking.nat = {
    enable = true;
    # Use "ve-*" when using nftables instead of iptables
    internalInterfaces = ["ve-+"];
    externalInterface = "enp2s0";
    # Lazy IPv6 connectivity for the container
    enableIPv6 = true;
  };

  containers = {
    shared-backups = {
      ephemeral = true;
      autoStart = true;
      privateNetwork = true;

      hostAddress = "192.168.100.10";
      localAddress = "192.168.100.1";
      hostAddress6 = "fc00::1";
      localAddress6 = "fc00::2";

      config = import ./shared-backups.nix;

      bindMounts = {
        "/secrets/wireguard" = {
          hostPath = "/secrets/wireguard/shared-backups";
          isReadOnly = true;
        };

        "/secrets/restic" = {
          hostPath = "/secrets/containers/shared-backups";
          isReadOnly = true;
        };

        "/data" = {
          hostPath = "/mnt/bigdata/shared-backups";
          isReadOnly = false;
        };
      };
    };
  };
}
