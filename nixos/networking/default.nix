{
  imports = [./wireguard.nix];

  config = {
    networking.firewall = {
      enable = true;
    };
  };
}
