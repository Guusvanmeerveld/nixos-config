{
  description = "A very basic flake";

  inputs = {
    # Latest stable packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    # Unstable packages
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";

    # Nix user repository
    nur.url = "github:nix-community/NUR";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nix-colors.url = "github:misterio77/nix-colors";

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Grub themes
    grub2-themes = {
      url = "github:vinceliuice/grub2-themes";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    # Configure neovim in Nix
    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    simple-nixos-mailserver = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay.url = "github:oxalica/rust-overlay";

    vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mconnect-nix = {
      url = "github:guusvanmeerveld/mconnect-nix";
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

    suyu = {
      url = "git+https://git.suyu.dev/suyu/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyperx-cloud-flight-s = {
      url = "github:guusvanmeerveld/hyperx-cloud-flight-s";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    microvm = {
      url = "github:astro/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    apple-fonts = {
      url = "github:lyndeno/apple-fonts.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
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

    shared = import ./shared;

    specialArgs = {inherit inputs outputs shared;};
  in {
    githubActions = nix-github-actions.lib.mkGithubMatrix {
      checks = nixpkgs.lib.getAttrs ["x86_64-linux"] self.packages;
    };

    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (
      with nixpkgs.lib; (
        system:
          (getAttr "export" (import ./pkgs {pkgs = nixpkgs.legacyPackages.${system};}))
          // {
            hyperx-cloud-flight-s = inputs.hyperx-cloud-flight-s.packages."${system}".default;
            mconnect = inputs.mconnect-nix.packages."${system}".default;
            sf-pro-nerd = inputs.apple-fonts.packages."${system}".sf-pro-nerd;
          }
      )
    );

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
      pkgs = import nixpkgs {system = "aarch64-linux";};
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
