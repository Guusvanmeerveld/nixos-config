{ pkgs, config, ... }:

{
  home.packages = with pkgs; [ heroic ];
}
