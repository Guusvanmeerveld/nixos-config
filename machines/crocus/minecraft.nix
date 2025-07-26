{
  inputs,
  lib,
  pkgs,
  ...
}: {
  imports = [inputs.nix-minecraft.nixosModules.minecraft-servers];
  nixpkgs.overlays = [inputs.nix-minecraft.overlay];

  networking.firewall.allowedUDPPorts = [
    19132 # Geyser port
    24454 # Simple Voice chat port
  ];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;

    managementSystem = {
      tmux.enable = false;
      systemd-socket.enable = true;
    };

    servers = {
      beasts-server = let
        mcVersion = "1.21.8";
        serverVersion = lib.replaceStrings ["."] ["_"] "paper-${mcVersion}";
      in {
        enable = true;
        package = pkgs.paperServers.${serverVersion};

        jvmOpts = "-Xmx8G -Xms2G";

        enableReload = true;

        symlinks = {
          "plugins/simple-voice-chat.jar" = pkgs.fetchurl rec {
            pname = "voicechat-bukkit";
            version = "2.5.35";
            url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/bNX2205a/${pname}-${version}.jar";
            hash = "sha256-s+a6RNulid9kiGkWYehbjpev0AWv8PgTsHWsBjWJB9g=";
          };
        };

        operators = {
          "Xeeon" = "a617bf06-976b-468f-8c4e-a0107aac2445";
        };

        serverProperties = {
          broadcast-rcon-to-ops = false;
          enable-rcon = false;
          difficulty = "hard";
          gamemode = "survival";
          motd = "fornite on steroids";
          pvp = true;
          server-port = 25565;
          simulation-distance = 10;
          view-distance = 12;
          spawn-protection = 0;
          white-list = true;
        };
      };
    };
  };
}
