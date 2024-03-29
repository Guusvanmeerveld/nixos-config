{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    unstable.url = "nixpkgs/nixos-unstable";

    nur.url = github:nix-community/NUR;
    grub2-themes.url = "github:vinceliuice/grub2-themes";

    agenix.url = "github:ryantm/agenix";

    nixvim = {
      url = "github:nix-community/nixvim/nixos-23.11";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, unstable, ... } @ inputs:
    let
      unstableOverlay = final: prev: { unstable = unstable.legacyPackages.${prev.system}; };
      unstableModule = ({ config, pkgs, ... }: { nixpkgs.overlays = [ unstableOverlay ]; });
      inherit (self) outputs;
    in
    {
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = { inherit inputs outputs; };
          modules = [
            ./machines/desktop/configuration.nix
            inputs.grub2-themes.nixosModules.default
          ];
        };
        laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = { inherit inputs outputs; };

          modules = [
            ./machines/laptop/configuration.nix
          ];
        };
      };

      homeConfigurations = {
        "guus@laptop" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;

          extraSpecialArgs = { inherit inputs outputs; };

          modules = [
            inputs.nixvim.homeManagerModules.nixvim
            inputs.nur.nixosModules.nur
            unstableModule
            ./machines/laptop/guus/home.nix
          ];
        };
        "guus@desktop" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;

          extraSpecialArgs = { inherit inputs outputs; };

          modules = [
            inputs.nixvim.homeManagerModules.nixvim
            inputs.nur.nixosModules.nur
            inputs.agenix.homeManagerModules.default
            unstableModule
            ./machines/desktop/guus/home.nix
          ];
        };
      };
    };
}
