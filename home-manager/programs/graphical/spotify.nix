{ config, pkgs, ... }:

{
  home.packages = with pkgs; [ spotifywm ];
}
