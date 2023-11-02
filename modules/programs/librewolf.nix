{ config, pkgs, ... }:

{
  programs.librewolf = {
    enable = true;

    settings = {
      "layout.css.devPixelsPerPx" = "1.33";
    };
  };
}