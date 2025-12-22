{lib, ...}: let
  resticPort = 8000;
in {
  networking = {
    firewall = {
      enable = true;

      allowedTCPPorts = [resticPort];
    };

    # Use systemd-resolved inside the container
    # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
    useHostResolvConf = lib.mkForce false;
  };

  services = {
    restic.server = {
      enable = true;

      dataDir = "/data";

      htpasswd-file = "/secrets/restic/htpasswdFile";
      listenAddress = "10.11.12.2:${toString resticPort}";
    };
  };

  systemd.network = {
    enable = true;

    netdevs."10-wireguard" = {
      netdevConfig = {
        Name = "wireguard";
        Kind = "wireguard";
        MTUBytes = "1420";
      };

      wireguardConfig = {
        PrivateKeyFile = "/secrets/wireguard/private";
        ListenPort = 51820;
      };

      wireguardPeers = [
        {
          PublicKey = "bRqHoLBezSYg2mYx1qHSdu/8c7ivuGMfnmzeJCRKZjQ=";
          AllowedIPs = "10.11.12.0/24";
          Endpoint = "141.148.241.201:49999";
          PersistentKeepalive = 25;
        }
      ];
    };

    networks."20-wireguard" = {
      matchConfig.Name = "wireguard";

      address = ["10.11.12.2/24"];

      linkConfig.RequiredForOnline = "no";
    };
  };

  system.stateVersion = "23.05";
}
