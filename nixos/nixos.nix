{
  lib,
  inputs,
  ...
}: {
  config = {
    systemd = {
      # Create a separate slice for nix-daemon that is
      # memory-managed by the userspace systemd-oomd killer
      slices."nix-daemon".sliceConfig = {
        ManagedOOMMemoryPressure = "kill";
        ManagedOOMMemoryPressureLimit = "50%";
      };
      services."nix-daemon".serviceConfig.Slice = "nix-daemon.slice";

      # If a kernel-level OOM event does occur anyway,
      # strongly prefer killing nix-daemon child processes
      services."nix-daemon".serviceConfig.OOMScoreAdjust = 1000;
    };

    nix = let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in {
      settings = {
        substituters = [
          "https://guusvanmeerveld.cachix.org"
          "https://nix-community.cachix.org"
          "https://nix-gaming.cachix.org"
        ];

        trusted-public-keys = [
          "guusvanmeerveld.cachix.org-1:DphRuosSBmhUyz2kLc9cvdHFl8N4mQm0QSxWxahvFuc="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
        ];

        experimental-features = ["nix-command" "flakes"];
        auto-optimise-store = true;
        warn-dirty = false;
      };

      # Opinionated: make flake registry and nix path match flake inputs
      registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
      channel.enable = false;

      gc = {
        automatic = true;
        options = "--delete-older-than 30d";
        dates = "weekly";
      };
    };

    programs.nh = {
      enable = true;
    };
  };
}
