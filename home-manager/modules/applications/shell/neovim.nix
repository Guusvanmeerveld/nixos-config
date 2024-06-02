{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.custom.applications.shell.neovim;
in {
  imports = [inputs.nixvim.homeManagerModules.nixvim];

  options = {
    custom.applications.shell.neovim = {
      enable = lib.mkEnableOption "Enable NeoVim text editor";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      enable = true;

      viAlias = true;

      colorschemes.onedark.enable = true;
      plugins.lightline.enable = true;

      opts = {
        number = true;
        relativenumber = true;
        ignorecase = true;
        smartcase = true;

        mouse = "a";

        termguicolors = true;

        shiftwidth = 2;
      };
    };
  };
}
