{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.networking.wireguard;

  networks = config.custom.shared.wireguard-networks;
in {
  options = {
    custom.networking.wireguard = {
      enable = lib.mkEnableOption "Enable Wireguard client";

      openFirewall = lib.mkEnableOption "Open default port";

      port = lib.mkOption {
        type = lib.types.port;
        description = "The port to use for Wireguard connections";
        default = 51820;
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
                  networkConfig.peers);
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

    # Map all domains of the peers in adguard.
    services.adguardhome.settings.filtering.rewrites = with lib;
      flatten (mapAttrsToList (
          networkName: network: let
            networkConfig = networks.${networkName};

            peers =
              [networkConfig.server]
              ++ (mapAttrsToList (_clientHostName: client: client) networkConfig.peers);

            peersWithDomains = filter (peer: (hasAttr "domains" peer) && (peer.domains != [])) peers;
          in
            lib.optionals network.enable (
              flatten (
                map (
                  peer: (map (domain: {
                      inherit domain;

                      answer = peer.address;
                      enabled = true;
                    })
                    peer.domains)
                )
                peersWithDomains
              )
            )
        )
        cfg.networks);

    systemd.network = {
      enable = true;

      netdevs = with lib;
        mapAttrs' (networkName: network: let
          networkConfig = networks.${networkName};

          isServer = networkConfig.server.hostname == config.networking.hostName;

          peers =
            if isServer
            then mapAttrsToList (_clientHostName: client: client) networkConfig.peers
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

          # List of all peers
          peers =
            [networkConfig.server]
            ++ (mapAttrsToList (_clientHostName: client: client) networkConfig.peers);

          peersWithDomains = filter (peer: (hasAttr "domains" peer) && (peer.domains != [])) peers;

          clientConfig =
            if isServer
            then networkConfig.server
            else networkConfig.peers.${config.networking.hostName};
        in
          mkIf network.enable (mkMerge [
            {
              matchConfig.Name = networkName;

              # Even if we cannot connect to Wireguard peers, we should still be able to be online
              linkConfig.RequiredForOnline = "no";

              address = ["${clientConfig.address}/24"];

              dns = [server];
              domains = flatten (
                map (
                  peer: (map (domain: replaceStrings ["*."] ["~"] domain) peer.domains)
                )
                peersWithDomains
              );

              networkConfig = lib.mkMerge [
                {
                  DNSOverTLS = false;
                  DNSSEC = false;
                }
                (mkIf (!isServer) {
                  IPv6AcceptRA = false;
                })
                (mkIf isServer {
                  IPv4Forwarding = true;
                  IPMasquerade = "ipv4";
                })
              ];
            }
          ]))
        cfg.networks;
    };
  };
}
