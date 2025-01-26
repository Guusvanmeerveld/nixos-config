{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.cli;
in {
  imports = [
    ./zsh.nix
    ./atuin.nix
    ./git.nix
    ./neovim.nix
    ./eza.nix
    ./utils.nix
    ./nix-index.nix
    ./fastfetch.nix
    ./tealdeer.nix
    ./starship.nix
  ];

  options = {
    custom.programs.cli = {
      default.enable = lib.mkEnableOption "Enable default shell applications";
    };
  };

  config = lib.mkIf cfg.default.enable {
    custom.programs.cli = {
      atuin.enable = lib.mkDefault true;
      eza.enable = lib.mkDefault true;
      git.enable = lib.mkDefault true;
      neovim.enable = lib.mkDefault true;
      nix-index.enable = lib.mkDefault true;
      zsh.enable = lib.mkDefault true;
      starship.enable = lib.mkDefault true;
      fastfetch.enable = lib.mkDefault true;
      tealdeer.enable = lib.mkDefault true;
    };
  };
}
