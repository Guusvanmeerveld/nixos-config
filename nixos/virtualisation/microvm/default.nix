{
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.custom.virtualisation.microvm;

  vmList = lib.mapAttrsToList (name: _: name) cfg.vms;

  vmMacAddrs = builtins.listToAttrs (
    map (vm: let
      hash = builtins.hashString "sha256" vm;
      c = off: builtins.substring off 2 hash;
      mac = "${builtins.substring 0 1 hash}2:${c 2}:${c 4}:${c 6}:${c 8}:${c 10}";
    in {
      name = vm;
      value = mac;
    })
    vmList
  );

  vmIPv4Addrs = builtins.listToAttrs (
    lib.imap0 (i: vm: {
      name = vm;
      value = "10.0.0.${toString (2 + i)}";
    })
    vmList
  );
in {
  imports = [inputs.microvm.nixosModules.host];

  options = {
    custom.virtualisation.microvm = {
      enable = lib.mkEnableOption "Enable MicroVM declarative containers";

      upstreamNetworkInterface = lib.mkOption {
        type = lib.types.str;
        description = "The network interface that provides internet access to the machine";
      };

      vms = lib.mkOption {
        type = with lib.types; attrsOf anything;
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (!cfg.enable) {
      microvm.host.enable = false;
    })
    (lib.mkIf cfg.enable {
      microvm.host.enable = true;

      # Configure networking for VM's
      systemd.network = {
        enable = true;

        netdevs."10-microvm".netdevConfig = {
          Kind = "bridge";
          Name = "microvm";
        };

        networks = {
          "10-microvm" = {
            matchConfig.Name = "microvm";

            networkConfig = {
              DHCPServer = true;
              IPv6SendRA = true;
            };

            # Configure static leases so the ips of the VM's don't change.
            dhcpServerStaticLeases =
              lib.imap0 (_i: vm: {
                dhcpServerStaticLeaseConfig = {
                  MACAddress = vmMacAddrs.${vm};
                  Address = vmIPv4Addrs.${vm};
                };
              })
              vmList;

            addresses = [
              {
                addressConfig.Address = "10.0.0.1/24";
              }
            ];
          };

          "11-microvm" = {
            matchConfig.Name = "vm-*";

            # Attach to the bridge that was configured above
            networkConfig = {
              Bridge = "microvm";
            };
          };
        };
      };

      networking = {
        useNetworkd = true;

        # Open firewall for dhcp.
        firewall = {
          allowedUDPPorts = [67];
        };

        # Enable NAT for internet access in the vms.
        nat = {
          enable = true;
          # NAT66 exists and works. But if you have a proper subnet in
          # 2000::/3 you should route that and remove this setting:
          # enableIPv6 = true;

          # Change this to the interface with upstream Internet access
          externalInterface = cfg.upstreamNetworkInterface;
          # The bridge where you want to provide Internet access
          internalInterfaces = ["microvm"];
        };

        # Add an extra hostname for every vm so they can be queried by DNS.
        extraHosts =
          lib.concatMapStrings (vm: ''
            ${vmIPv4Addrs.${vm}} ${vm}
          '')
          vmList;
      };

      microvm = {
        vms =
          builtins.mapAttrs (vm: vmConfig: let
            mac = vmMacAddrs.${vm};
          in {
            config = {
              imports = [vmConfig];

              system.stateVersion = "24.11";

              systemd.network.enable = true;

              microvm.interfaces = [
                {
                  type = "tap";
                  id = "vm-${builtins.substring 0 12 vm}";
                  inherit mac;
                }
              ];

              networking.hostName = "${vm}-microvm";
            };
          })
          cfg.vms;
      };
    })
  ];
}
