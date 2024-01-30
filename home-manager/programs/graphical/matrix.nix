{ pkgs, ... }: {
  home.packages = with pkgs; [
    schildichat-desktop
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "schildichat-web-1.11.30-sc.2"
    "electron-25.9.0"
  ];

}
