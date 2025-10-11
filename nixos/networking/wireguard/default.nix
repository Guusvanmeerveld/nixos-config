{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.networking.wireguard;

  networks = {
    garden = {
      ipRange = "10.10.10.0/24";

      server = {
        publicKey = "UjJqjYvUcSl4dGcfRgPWAyNHvHPqo51MApKixc+h3RQ="; # pragma: allowlist secret
        address = "10.10.10.1";
        hostname = "crocus";
        tld = "crocus";
        endpoint = "143.47.189.158";
      };

      clients = {
        desktop = {
          publicKey = "dVOXBUprtiJSOMazEujx0zh7m86YEoXDdQ3muMpQIHw="; # pragma: allowlist secret
          address = "10.10.10.2";
          tld = "desktop";
        };

        laptop = {
          publicKey = "4cfYFYG7zvU+Hy1hVRT1rbNBbeVXCKy9GoRP6Mpv738="; # pragma: allowlist secret
          address = "10.10.10.3";
          tld = "laptop";
        };

        phone = {
          publicKey = "/JKDqqU3tVqKJP4tlcOol5VacFu0Ea4cLRwMjFbqj1M="; # pragma: allowlist secret
          address = "10.10.10.4";
          tld = "phone";
        };

        tulip = {
          publicKey = "/7j5rVEgQVe4eVY6v/DkA+tn/IXqxH+X7641iAPPa38="; # pragma: allowlist secret
          address = "10.10.10.5";
          tld = "tlp";
        };

        thuisthuis = {
          publicKey = "6lNZjXUkvfdG1prJVJh7yl32yRU1j+2+Suhyq8XySmU="; # pragma: allowlist secret
          address = "10.10.10.6";
          tld = "thsths";
        };

        daisy = {
          publicKey = "WvESBhla1yU9irR4izmGRJuifyrFT47Qry1JsLgcXhY="; # pragma: allowlist secret
          address = "10.10.10.7";
          tld = "dsy";
        };

        rose = {
          publicKey = "HNKWUiePIoh48jayDHxVF/iAcx2JXLHbneKMVDayqg8="; # pragma: allowlist secret
          address = "10.10.10.8";
          tld = "rose";
        };

        pd = {
          publicKey = "1QdndFE7pZAGA47U0O/1VErl3VNZnRFMNY+xksX9HAQ="; # pragma: allowlist secret
          address = "10.10.10.9";
          tld = "peerdroog";
        };

        orchid = {
          publicKey = "GTL4lYhzwhrk72/Rr6vaamGo8txoj/Cy3hpGSiNvt18="; # pragma: allowlist secret
          address = "10.10.10.10";
          tld = "chd";
        };

        dd = {
          publicKey = "NW5fh6w2GjK+gXlZvkIq1MrPNOhvTxHF7iKDiWiWEwg="; # pragma: allowlist secret
          address = "10.10.10.11";
          tld = "daniel";
        };

        framework-13 = {
          publicKey = "3UWmaWdtyboiSfib2i33TmUZcV6t6eogzsGv2BCIZXs="; # pragma: allowlist secret
          address = "10.10.10.12";
          tld = "fw13";
        };

        sunflower = {
          publicKey = "cuSlka1YtuRd1GX3mVrbcI2Ig9plLt1lQtDf9Ehs0Bc="; # pragma: allowlist secret
          address = "10.10.10.13";
          tld = "sun";
        };
      };
    };
  };
in {
  options = {
    custom.networking.wireguard = {
      enable = lib.mkEnableOption "Enable Wireguard client";

      openFirewall = lib.mkEnableOption "Open default port";

      port = lib.mkOption {
        type = lib.types.port;
        description = "The port to use for Wireguard connections";
        default = 49999;
      };

      networks = lib.mkOption {
        type = with lib.types;
          attrsOf (submodule ({name, ...}: {
            options = {
              enable = lib.mkEnableOption "Enable this network";

              privateKeyFile = lib.mkOption {
                type = lib.types.str;
                default = "/secrets/wireguard/${name}/private";
              };

              keepAlive = lib.mkEnableOption "Send keep alive to main server to keep NAT open";
            };
          }));
        default = {};
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      firewall = {
        allowedUDPPorts = lib.optional cfg.openFirewall cfg.port;

        # This allows wireguard clients on NixOS to have outgoing traffic. See: https://nixos.wiki/wiki/WireGuard#Setting_up_WireGuard_with_NetworkManager
        checkReversePath = "loose";
      };

      # Add all Wireguard peers to hosts file.
      hosts = with lib;
        mkMerge (mapAttrsToList (
            networkName: network: let
              networkConfig = networks.${networkName};

              peers =
                [
                  {
                    name = networkConfig.server.hostname;
                    ip = networkConfig.server.address;
                  }
                ]
                ++ (mapAttrsToList (clientHostName: client: {
                    name = clientHostName;
                    ip = client.address;
                  })
                  networkConfig.clients);
            in
              lib.optionals network.enable (listToAttrs (map (peer: {
                  name = peer.ip;
                  value = [peer.name];
                })
                peers))
          )
          cfg.networks);
    };

    environment.systemPackages = with pkgs; [wireguard-tools];

    services.resolved.extraConfig = ''
      DNSStubListener=no
    '';

    # Map all TLD's of the peers in adguard.
    services.adguardhome.settings.filtering.rewrites = with lib;
      flatten (mapAttrsToList (
          networkName: network: let
            networkConfig = networks.${networkName};

            peers =
              [networkConfig.server]
              ++ (mapAttrsToList (_clientHostName: client: client) networkConfig.clients);
          in
            lib.optionals network.enable (map (
                peer: {
                  domain = "*.${peer.tld}";
                  answer = peer.address;
                }
              )
              peers)
        )
        cfg.networks);

    systemd.network = {
      enable = true;

      # Rebuild will get stuck if using systemd-networkd together with NetworkManager.
      wait-online.enable = false;

      netdevs = with lib;
        mapAttrs' (networkName: network: let
          networkConfig = networks.${networkName};

          isServer = networkConfig.server.hostname == config.networking.hostName;

          peers =
            if isServer
            then mapAttrsToList (_clientHostName: client: client) networkConfig.clients
            else singleton networkConfig.server;
        in
          nameValuePair "10-${networkName}" (
            mkIf network.enable
            {
              netdevConfig = {
                Name = networkName;
                Kind = "wireguard";
                MTUBytes = "1420";
              };

              wireguardConfig = {
                PrivateKeyFile = network.privateKeyFile;
                ListenPort = cfg.port;
              };

              wireguardPeers =
                map (peer: {
                  PublicKey = peer.publicKey;

                  # If we are the server, we need to assign the client an ip.
                  AllowedIPs =
                    if isServer
                    then peer.address
                    else networkConfig.ipRange;

                  Endpoint = lib.mkIf (builtins.hasAttr "endpoint" peer) "${peer.endpoint}:${
                    toString (
                      if builtins.hasAttr "port" peer
                      then peer.port
                      else cfg.port
                    )
                  }";

                  PersistentKeepalive =
                    # If the client needs keep alive, then enable it.
                    if network.keepAlive
                    then 25
                    else 0;
                })
                peers;
            }
          ))
        cfg.networks;

      networks = with lib;
        mapAttrs (networkName: network: let
          networkConfig = networks.${networkName};
          server = networkConfig.server.address;
          isServer = networkConfig.server.hostname == config.networking.hostName;

          clientConfig =
            if isServer
            then networkConfig.server
            else networkConfig.clients.${config.networking.hostName};
        in
          mkIf network.enable (mkMerge [
            {
              matchConfig.Name = networkName;

              address = ["${clientConfig.address}/24"];

              dns = [server];

              networkConfig = mkIf isServer {
                IPv4Forwarding = true;
                IPMasquerade = "ipv4";
              };
            }
            (optionalAttrs (!isServer) {
              networkConfig = {
                IPv6AcceptRA = false;
              };
            })
          ]))
        cfg.networks;
    };
  };
}
