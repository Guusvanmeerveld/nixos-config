{
  description = "NixOS configurations for all my personal machines & servers";

  inputs = {
    # Latest packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";

    # Nix user repository
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nix-colors.url = "github:misterio77/nix-colors";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    vscode-server.url = "github:nix-community/nixos-vscode-server";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Configure neovim in Nix
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mconnect-nix = {
      url = "github:guusvanmeerveld/mconnect-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    argonone-nix = {
      url = "github:guusvanmeerveld/argonone-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    docker-compose-nix = {
      url = "github:guusvanmeerveld/docker-compose-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-github-actions = {
      url = "github:nix-community/nix-github-actions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyperx-cloud-flight-s = {
      url = "github:guusvanmeerveld/hyperx-cloud-flight-s";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    apple-fonts = {
      url = "github:lyndeno/apple-fonts.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    jellyfin-plugins = {
      url = "github:LoCrealloc/jellyfin-plugins-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vpn-confinement.url = "github:Maroka-chan/VPN-Confinement";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://guusvanmeerveld.cachix.org"
    ];
    extra-trusted-public-keys = [
      "guusvanmeerveld.cachix.org-1:DphRuosSBmhUyz2kLc9cvdHFl8N4mQm0QSxWxahvFuc="
    ];
  };

  outputs = {
    self,
    nixpkgs,
    nix-github-actions,
    nix-on-droid,
    pre-commit-hooks,
    nixos-generators,
    ...
  } @ inputs: let
    systems = [
      "aarch64-linux"
      # "i686-linux"
      "x86_64-linux"
      # "aarch64-darwin"
      # "x86_64-darwin"
    ];

    forAllSystems = nixpkgs.lib.genAttrs systems;

    inherit (self) outputs;
    inherit (nixpkgs) lib;

    shared = import ./shared;

    specialArgs = {inherit inputs outputs shared;};
  in {
    githubActions = nix-github-actions.lib.mkGithubMatrix {
      checks = lib.getAttrs ["x86_64-linux"] self.packages;
    };

    checks = forAllSystems (system: {
      pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          # Formatter for Nix code.
          alejandra.enable = true;

          # Check for Nix code that is unused.
          deadnix.enable = true;

          nil.enable = true;

          # Linter fox Nix code.
          statix = {
            enable = true;
            settings.ignore = ["hardware-configuration.nix"];
          };

          # Check if in-use version of nixpkgs is still maintained.
          flake-checker.enable = true;
        };
      };
    });

    devShells = forAllSystems (system: {
      default = nixpkgs.legacyPackages.${system}.mkShell {
        # Create pre commit hooks upon entering the development shell
        inherit (self.checks.${system}.pre-commit-check) shellHook;

        # Adds all the packages related to the pre commit hooks.
        buildInputs = self.checks.${system}.pre-commit-check.enabledPackages;
      };
    });

    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages =
      (forAllSystems (
        with lib; (
          system:
            (getAttr "export" (import ./pkgs {pkgs = nixpkgs.legacyPackages.${system};}))
            // {
              inherit (inputs.apple-fonts.packages."${system}") sf-pro-nerd;

              hyperx-cloud-flight-s = inputs.hyperx-cloud-flight-s.packages."${system}".default;
              mconnect = inputs.mconnect-nix.packages."${system}".default;
            }
        )
      ))
      // {
        aarch64-linux = {
          orchid = nixos-generators.nixosGenerate {
            inherit specialArgs;

            system = "aarch64-linux";
            format = "sd-aarch64";

            modules = [
              ./machines/orchid/configuration.nix
            ];
          };
        };
      };

    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};

    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;

    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    homeManagerModules = import ./modules/home-manager;

    nixOnDroidConfigurations.default = nix-on-droid.lib.nixOnDroidConfiguration {
      extraSpecialArgs = specialArgs;

      pkgs = import nixpkgs {
        system = "aarch64-linux";

        overlays = [
          nix-on-droid.overlays.default
        ];
      };

      modules = [./machines/phone/configuration.nix];
    };

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        inherit specialArgs;

        modules = [
          ./machines/desktop/configuration.nix
        ];
      };

      thuisthuis = nixpkgs.lib.nixosSystem {
        inherit specialArgs;

        modules = [
          ./machines/thuisthuis/configuration.nix
        ];
      };

      laptop = nixpkgs.lib.nixosSystem {
        inherit specialArgs;

        modules = [
          ./machines/laptop/configuration.nix
        ];
      };

      vm = nixpkgs.lib.nixosSystem {
        inherit specialArgs;

        modules = [
          ./machines/vm/configuration.nix
        ];
      };

      rose = nixpkgs.lib.nixosSystem {
        inherit specialArgs;

        modules = [
          ./machines/rose/configuration.nix
        ];
      };

      daisy = nixpkgs.lib.nixosSystem {
        inherit specialArgs;

        modules = [
          ./machines/daisy/configuration.nix
        ];
      };

      crocus = nixpkgs.lib.nixosSystem {
        inherit specialArgs;

        modules = [
          ./machines/crocus/configuration.nix
        ];
      };

      lavender = nixpkgs.lib.nixosSystem {
        inherit specialArgs;

        modules = [
          ./machines/lavender/configuration.nix
        ];
      };

      orchid = nixpkgs.lib.nixosSystem {
        inherit specialArgs;

        modules = [
          ./machines/orchid/configuration.nix
        ];
      };

      tulip = nixpkgs.lib.nixosSystem {
        inherit specialArgs;

        modules = [
          ./machines/tulip/configuration.nix
        ];
      };
    };
  };
}
