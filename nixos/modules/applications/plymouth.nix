{ pkgs, config, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      plymouth
    ];

    boot.plymouth.enable = true;
  };
}
