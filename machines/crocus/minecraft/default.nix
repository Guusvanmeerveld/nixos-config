{
  inputs,
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    inputs.nix-minecraft.nixosModules.minecraft-servers
    ./enigmatica
  ];

  nixpkgs.overlays = [inputs.nix-minecraft.overlay];

  networking.firewall.allowedUDPPorts = [
    19132 # Geyser port
    24454 # Simple Voice chat port
  ];

  custom.services.restic.client.backups.minecraft-beasts-server = {
    services = ["minecraft-server-beasts-server"];

    files = let
      dataDir = "${config.services.minecraft-servers.dataDir}/beasts-server";
    in [
      "${dataDir}/world"
      "${dataDir}/world_nether"
      "${dataDir}/world_the_end"
      "${dataDir}/config"
    ];
  };

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
        mcVersion = "1.21.11";
        serverVersion = lib.replaceStrings ["."] ["_"] "fabric-${mcVersion}";
      in {
        enable = true;

        package = pkgs.fabricServers.${serverVersion};

        jvmOpts = lib.concatStringsSep " " [
          "-Xms10G"
          "-Xmx10G"
          "-XX:+UseG1GC"
          "-XX:+ParallelRefProcEnabled"
          "-XX:MaxGCPauseMillis=200"
          "-XX:+UnlockExperimentalVMOptions"
          "-XX:+DisableExplicitGC"
          "-XX:+AlwaysPreTouch"
          "-XX:G1NewSizePercent=30"
          "-XX:G1MaxNewSizePercent=40"
          "-XX:G1HeapRegionSize=8M"
          "-XX:G1ReservePercent=20"
          "-XX:G1HeapWastePercent=5"
          "-XX:G1MixedGCCountTarget=4"
          "-XX:InitiatingHeapOccupancyPercent=15"
          "-XX:G1MixedGCLiveThresholdPercent=90"
          "-XX:G1RSetUpdatingPauseTimePercent=5"
          "-XX:SurvivorRatio=32"
          "-XX:+PerfDisableSharedMem"
          "-XX:MaxTenuringThreshold=1"
          "-Dusing.aikars.flags=https://mcflags.emc.gs"
          "-Daikars.new.flags=true"
        ];

        symlinks = {
          "mods/ferritecore.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/uXXizFIs/versions/Ii0gP3D8/ferritecore-8.2.0-fabric.jar";
            hash = "sha256-92vXYMv0goDMfEMYD1CJpGI1+iTZNKis89oEpmTCxxU=";
          };

          "mods/lithium.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/qvNsoO3l/lithium-fabric-0.21.3%2Bmc1.21.11.jar";
            hash = "sha256-hsG97K3MhVgBwvEMnlKJTSHJPjxSl8qDJwdN3RIeXFo=";
          };

          "mods/nochatreports.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/qQyHxfxd/versions/rhykGstm/NoChatReports-FABRIC-1.21.11-v2.18.0.jar";
            hash = "sha256-FIAjmJ8BT98BLlDYpDp1zErTkZn4mBT1yMo43N7+ELg=";
          };

          "mods/krypton.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/fQEb0iXm/versions/O9LmWYR7/krypton-0.2.10.jar";
            hash = "sha256-lCkdVpCgztf+fafzgP29y+A82sitQiegN4Zrp0Ve/4s=";
          };

          "mods/c2me.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/VSNURh3q/versions/olrVZpJd/c2me-fabric-mc1.21.11-0.3.6.0.0.jar";
            hash = "sha256-DwWNNWBfzM3xl+WpB3QDSubs3yc/NMMV3c1I9QYx3f8=";
          };

          "mods/distanthorizons.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/uCdwusMi/versions/GT3Bm3GN/DistantHorizons-2.4.5-b-1.21.11-fabric-neoforge.jar";
            hash = "sha256-dpTHoX5V9b7yG0VsIqKxxOSAYLN0Z97itx1MEuWGvD8=";
          };

          "mods/spark.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/l6YH9Als/versions/1CB3cS0m/spark-1.10.156-fabric.jar";
            hash = "sha256-Nu0Tj/3iovH8sy7LzH+iG+rxYR4APRnjrUCVSHPlcvo=";
          };

          "mods/simplevoicechat.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/pFTZ8sqQ/voicechat-fabric-1.21.11-2.6.12.jar";
            hash = "sha256-HwedHcqW2UhPdxPNROKWUcwIxAp0kj0gSdB7/dX3bcA=";
          };

          # Libs
          "mods/fabric-api.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/i5tSkVBH/fabric-api-0.141.3%2B1.21.11.jar";
            hash = "sha256-hsRTqGE5Zi53VpfQOwynhn9Uc3SGjAyz49wG+Y2/7vU=";
          };
        };

        operators = {
          "Xeeon" = "a617bf06-976b-468f-8c4e-a0107aac2445";
          "Gerda6" = "f4307d4d-29a0-4721-ab0e-95f790722383";
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
