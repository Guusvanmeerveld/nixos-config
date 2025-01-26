{...}: {
  config = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    # nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

    # nix.nixPath = ["/etc/nix/path"];
    # environment.etc =
    #   lib.mapAttrs'
    #   (name: value: {
    #     name = "nix/path/${name}";
    #     value.source = value.flake;
    #   })
    #   config.nix.registry;

    nix = {
      settings = {
        substituters = [
          "https://guusvanmeerveld.cachix.org"
          "https://nix-community.cachix.org"
        ];

        trusted-public-keys = [
          "guusvanmeerveld.cachix.org-1:DphRuosSBmhUyz2kLc9cvdHFl8N4mQm0QSxWxahvFuc="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];

        experimental-features = ["nix-command" "flakes"];
        auto-optimise-store = true;
        warn-dirty = false;
      };

      # gc = {
      #   automatic = true;
      #   options = "--delete-older-than 30d";
      #   dates = "weekly";
      # };
    };

    programs.nh = {
      enable = true;

      clean = {
        enable = true;
        dates = "Mon *-*-08..14 05:00:00";
        extraArgs = "--keep-since 14d --keep 3";
      };
    };
  };
}
