{
  config,
  pkgs,
  ...
}: {
  config = {
    networking.firewall = {
      enable = true;
    };
  };
}
