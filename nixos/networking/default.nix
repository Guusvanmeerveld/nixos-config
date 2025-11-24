{
  imports = [
    ./wireguard
  ];

  config = {
    networking.firewall = {
      enable = true;
    };
  };
}
