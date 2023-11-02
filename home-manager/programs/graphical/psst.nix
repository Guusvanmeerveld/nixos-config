{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ psst ];
}
