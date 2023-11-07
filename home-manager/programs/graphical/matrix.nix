{ pkgs, ... }: {
  home.packages = with pkgs; [
    cinny-desktop
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
  ];

}
