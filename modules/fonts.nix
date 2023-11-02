{ pkgs, ... }:

{
  fonts.fonts = with pkgs; [
     noto-fonts
     noto-fonts-cjk
     noto-fonts-emoji
     fira-code
     fira-code-symbols
     meslo-lgs-nf
  ];
}