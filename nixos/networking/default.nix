{
  imports = [
    ./wireguard
    ./mullvad.nix
  ];

  config = {
    networking.firewall = {
      enable = true;
    };
  };
}
