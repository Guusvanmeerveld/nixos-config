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
      ])
      ++ (with pkgs.custom.scripts; [manage-secrets]);
  };
}
