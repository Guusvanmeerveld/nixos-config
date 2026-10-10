{pkgs, ...}: {
  config = {
    environment.systemPackages =
      (with pkgs; [
        bottom
        htop
        vim
        unzip
        zip
        doggo
        jq
        home-manager
        git
        subversionClient
      ])
      ++ (with pkgs.custom.scripts; [manage-secrets]);
  };
}
