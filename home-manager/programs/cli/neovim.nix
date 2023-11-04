{ config, pkgs, inputs, ... }:

{
  programs.nixvim = {
    enable = true;

    viAlias = true;

    colorschemes.onedark.enable = true;
    plugins.lightline.enable = true;

    options = {
      number = true;
      relativenumber = true;
      ignorecase = true;
      smartcase = true;

      mouse = "a";

      termguicolors = true;

      shiftwidth = 2;
    };

  };
}
