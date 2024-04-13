{pkgs, ...}: {
  config = {
    programs.git.enable = true;

    environment.systemPackages = with pkgs; [
      bottom
      htop
      vim
      unzip
      zip
      doggo
      jq
      home-manager
    ];
  };
}
