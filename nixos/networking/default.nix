{
  imports = [
    ./wireguard.nix
    ./mullvad.nix
  ];

  config = {
    networking.firewall = {
      enable = true;
    };
  };
}
