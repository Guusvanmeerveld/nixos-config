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
        mcVersion = "26.2";
        serverVersion = lib.replaceStrings ["."] ["_"] "fabric-${mcVersion}";
      in {
        enable = true;

        package = pkgs.fabricServers.${serverVersion}.override {
          loaderVersion = "0.19.3";
          jre_headless = pkgs.openjdk25;
        };

        jvmOpts = lib.concatStringsSep " " [
          "-Xms6G"
          "-Xmx8G"
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
            url = "https://cdn.modrinth.com/data/uXXizFIs/versions/d5ddUdiB/ferritecore-9.0.0-fabric.jar";
            hash = "sha256-ITlmxy7ZZ6zHOSvrKKhm+6MB/1a5l2wueAHC233mvyI=";
          };

          "mods/lithium.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/f7vZ0VWU/lithium-fabric-0.25.3%2Bmc26.2.jar";
            hash = "sha256-/d6S4jjoB1+JrX9wHyo9WFSviLqaZ2VxhKRAexBKxWM=";
          };

          "mods/nochatreports.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/qQyHxfxd/versions/aDbxaVTi/NoChatReports-FABRIC-26.2-v2.20.2.jar";
            hash = "sha256-k8dh6ft9diaaDVuYB+GdsWSzov0Ljr0FUP6U+DLPOW8=";
          };

          "mods/krypton.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/fQEb0iXm/versions/5WeL0Nkz/krypton-0.3.1.jar";
            hash = "sha256-XqiQFWGXPSnlHnUUadUtkhAPNIq0YeEYb2cBLpNCDEg=";
          };

          "mods/c2me.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/VSNURh3q/versions/jSMMstCy/c2me-fabric-mc26.2-0.4.2-alpha.0.43.jar";
            hash = "sha256-sBMik4P1F4nFdoTLz8EpgcjXkSBvO1lIZt/rdK7Tdws=";
          };

          "mods/spark.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/l6YH9Als/versions/iYFOl6lQ/spark-1.10.173-fabric.jar";
            hash = "sha256-B27SKI2yoFym6AYWFeGjHRkSzxsQZl5PCaF5TV25lDM=";
          };

          "mods/simplevoicechat.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/9eGKb6K1/versions/DKSq5wO6/voicechat-fabric-2.6.22%2B26.2.jar";
            hash = "sha256-G2qMbEHW1+2qEFQ6xiOnCwxg8i80VnlptpmcNFqid7I=";
          };

          "mods/disconnect-packet-fix.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/rd9rKuJT/versions/8bBHJTea/disconnect-packet-fix-fabric-2.2.0.jar";
            hash = "sha256-Zq8uVTJIBRadJjSowqiitvj7k1+jeAhBWZGOgQdjPHc=";
          };

          "mods/dcintegration.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/rbJ7eS5V/versions/ZZwadcBm/dcintegration-fabric-MC26.2-3.2.0.jar";
            hash = "sha256-3y8nxmdwNfFIrrwQDVnuPyyJUGgZT4lrY/m1uajuLEM=";
          };

          # Libs
          "mods/fabric-api.jar" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/BgeCGgGZ/fabric-api-0.159.0%2B26.2.jar";
            hash = "sha256-Pzpdluao9VSnLnH7UH1ql5yhbZGQwwXOsTAPHQHnM+4= ";
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
