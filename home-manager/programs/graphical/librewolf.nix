{ config, pkgs, inputs, ... }:

{
  programs.librewolf = {
    enable = true;

    # extensions = with inputs.nur.repos; [
    #   bitwarden
    # ];
  };
}