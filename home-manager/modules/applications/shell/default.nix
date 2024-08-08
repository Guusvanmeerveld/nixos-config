{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.shell;
in {
  imports = [./zsh.nix ./atuin.nix ./git.nix ./neovim.nix ./eza.nix ./utils.nix ./nix-index.nix ./fastfetch.nix];

  options = {
    custom.applications.shell = {
      default.enable = lib.mkEnableOption "Enable default shell applications";
    };
  };

  config = lib.mkIf cfg.default.enable {
    custom.applications.shell = {
      atuin.enable = true;
      eza.enable = true;
      git.enable = true;
      neovim.enable = true;
      nix-index.enable = true;
      zsh.enable = true;
      fastfetch.enable = true;
    };
  };
}
