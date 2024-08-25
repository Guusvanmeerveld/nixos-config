# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{...}: {
  imports = [
    ../../nixos/modules

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.tmp.cleanOnBoot = true;

  # zramSwap.enable = true;

  networking.hostName = "crocus";

  # Enable networking
  networking.networkmanager.enable = true;

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "security@guusvanmeerveld.dev";

  networking.firewall.allowedTCPPorts = [80 443];

  custom = {
    user = {
      name = "guus";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBe0+LH36GZnNZESUxkhLKSQ0BucJbPL4UARfTwwczSq guus@desktop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINtf3QLEGFwNipavG1GIuX122Wy0zhh6kl0yEOGp8UTW guus@laptop"
      ];
    };

    applications = {
      services = {
        minecraft = {
          openFirewall = true;
          openGeyserFirewall = true;
          openVoiceChatFirewall = true;
        };

        syncthing.openFirewall = true;
        
        docker = {
          enable = true;

          watchtower = {
            enable = true;
            schedule = "0 0 5 * * 1";
          };
        };

        openssh.enable = true;
        fail2ban.enable = true;
      };

      wireguard = {
        openFirewall = true;
        kernelModules.enable = true;
      };

      shell.zsh.enable = true;
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
