{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.networking.wireguard;
in {
  options = {
    custom.networking.wireguard = {
      enable = lib.mkEnableOption "Enable Wireguard client";

      kernelModules.enable = lib.mkEnableOption "Enable Wireguard kernel modules";

      openFirewall = lib.mkEnableOption "Open default port";

      port = lib.mkOption {
        type = lib.types.port;
        description = "The port to use for Wireguard connections";
        default = 51820;
      };

      interfaces = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            addresses = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              description = "Determines the IP address and subnet of this machine's end of the tunnel interface.";
            };

            clientConfig = {
              enable = lib.mkEnableOption "Whether this interface should behave like a client connection";

              server = lib.mkOption {
                type = lib.types.str;
                description = "The ip address of the wireguard client that is acting as the server.";
              };
            };

            privateKeyFile = lib.mkOption {
              type = lib.types.str;
              description = "The absolute path to the private key file";
            };

            peers = lib.mkOption {
              type = lib.types.listOf (lib.types.submodule {
                options = {
                  publicKey = lib.mkOption {
                    type = lib.types.str;
                    description = "This peer's public key (not a file path)";
                  };

                  allowedIps = lib.mkOption {
                    type = lib.types.listOf lib.types.str;
                    description = "List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.";
                  };

                  endpoint = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    default = null;
                    description = "The peer's IP and port";
                    example = "123.123.123.123:51820";
                  };

                  keepAlive = lib.mkOption {
                    type = lib.types.ints.unsigned;
                    default = 0;
                    description = "Whether to send a keep alive packet to the peer every x seconds";
                  };
                };
              });
              description = "A list of peers";
            };
          };
        });
        description = "A map of the Wireguard interfaces";
        default = {};
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall = {
      allowedUDPPorts = lib.optional cfg.openFirewall cfg.port;
    };

    networking.firewall.checkReversePath = "loose";

    environment.systemPackages = with pkgs; [wireguard-tools];

    services.resolved.extraConfig = ''
      DNSStubListener=no
    '';

    systemd.network = {
      enable = true;

      # Rebuild will get stuck if using systemd-networkd together with NetworkManager.
      wait-online.enable = false;

      netdevs = lib.mapAttrs' (name: interface:
        lib.nameValuePair "10-${name}" {
          netdevConfig = {
            Name = name;
            Kind = "wireguard";
            MTUBytes = "1420";
          };

          wireguardConfig = {
            PrivateKeyFile = interface.privateKeyFile;
            ListenPort = cfg.port;
          };

          wireguardPeers =
            map (peer: {
              PublicKey = peer.publicKey;
              AllowedIPs = peer.allowedIps;
              Endpoint = lib.mkIf (peer.endpoint != null) peer.endpoint;
              PersistentKeepalive = peer.keepAlive;
            })
            interface.peers;
        })
      cfg.interfaces;

      networks = lib.mapAttrs (name: interface:
        lib.mkMerge [
          {
            matchConfig.Name = name;

            address = interface.addresses;

            networkConfig = lib.mkIf (!interface.clientConfig.enable) {
              IPv4Forwarding = true;
              IPMasquerade = "ipv4";
            };
          }
          (lib.optionalAttrs interface.clientConfig.enable (let
            server = interface.clientConfig.server;
          in {
            dns = [server];

            networkConfig = {
              IPv6AcceptRA = false;
            };
          }))
        ])
      cfg.interfaces;
    };
  };
}
