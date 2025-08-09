{
  pkgs,
  inputs,
  lib,
  ...
}: let
  inherit (inputs.nix-minecraft.lib) collectFilesAt;

  modpack = pkgs.stdenv.mkDerivation rec {
    pname = "enigmatica-10";
    version = "1.24.1";

    src = pkgs.fetchurl {
      url = "https://edge.forgecdn.net/files/6745/900/Enigmatica10-${version}.zip";
      hash = "sha256-b6bWQgXt4830T7mryOxyXLFEflf+7vNOZVdqkPwthz4=";
    };

    buildInputs = with pkgs; [unzip];

    unpackPhase = let
      ignoredFiles = [
        "resources/**"
        "packmenu/**"
        "kubejs/assets/**"
        "kubejs/client_scripts/**"
        "building_gadgets_patterns/**"
        "config/*-client.toml"
        "defaultconfigs/*-client.toml"
        "local/**"
      ];
    in ''
      mkdir -p $out
      unzip $src
      rm -r overrides/{${lib.concatStringsSep "," ignoredFiles}}
      mv overrides/* manifest.json $out
    '';
  };

  neoforge = pkgs.fetchurl rec {
    pname = "neoforge-installer";
    version = "21.1.170";

    url = "https://maven.neoforged.net/releases/net/neoforged/neoforge/${version}/neoforge-${version}-installer.jar";
    hash = "sha256-XBwe/FJS4O40FIz0O3zT3LHRybfKDqzFj6TPNY61cNs=";
  };
in {
  services.minecraft-servers.servers.enigmatica-10 = {
    enable = true;
    enableReload = true;

    package = pkgs.writeShellApplication {
      name = "neoforge-start";

      runtimeInputs = with pkgs; [openjdk21 bash];

      text = ''
        if ! [ -e "run.sh" ]; then
          java -jar ${neoforge} --installServer
        fi

        exec ./run.sh nogui
      '';
    };

    jvmOpts = lib.concatStringsSep " " [
      "-Xmx12G"
      "-Xms2G"
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
      "-Dfml.readTimeout=180" # servertimeout
      "-Dfml.queryResult=confirm" # auto /fmlconfirm
    ];

    files =
      collectFilesAt modpack "config"
      // collectFilesAt modpack "defaultconfigs"
      // {
        "mods" = "/var/lib/minecraft/enigmatica-10/mods";
        "config/AdvancedBackups.properties" = ./config/AdvancedBackups.properties;
      };

    operators = {
      "Xeeon" = "a617bf06-976b-468f-8c4e-a0107aac2445";
    };

    whitelist = {
      "Xeeon" = "a617bf06-976b-468f-8c4e-a0107aac2445";
      "maxlyre" = "256c70c8-8b5e-45b2-a2d1-d9286fd4f465";
      "Gerda6" = "f4307d4d-29a0-4721-ab0e-95f790722383";
      "IAngryDonut" = "8035043d-4d51-416f-b396-a3c391d24c72";
    };

    serverProperties = {
      broadcast-rcon-to-ops = false;
      enable-rcon = false;
      difficulty = "medium";
      gamemode = "survival";
      pvp = true;
      allow-flight = true;
      server-port = 25565;
      simulation-distance = 10;
      view-distance = 12;
      spawn-protection = 0;
      white-list = true;
    };
  };
}
