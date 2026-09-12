{lib, ...} @ params:
rec {
  relativeToRoot = lib.path.append ../.;

  getDeviceWireguardIp = let
    wireguardNetworks = import (relativeToRoot "shared/wireguard-networks.nix") {inherit lib;};
    networks = wireguardNetworks.config.custom.shared.wireguard-networks;
  in
    network: device: let
      peers =
        networks.${network}.peers
        // {
          "${networks.${network}.server.hostname}" = {
            inherit (networks.${network}.server) address;
          };
        };
    in
      peers.${device}.address;

  hexToDecimal = hex: (fromTOML "a = 0x${hex}").a;

  makeTransparent = hex: transparancy: let
    r = hexToDecimal (builtins.substring 1 2 hex);
    g = hexToDecimal (builtins.substring 3 2 hex);
    b = hexToDecimal (builtins.substring 5 2 hex);
    a = transparancy; # Set your desired alpha value here (0.0 to 1.0)
  in "rgba(${toString r}, ${toString g}, ${toString b}, ${toString a})";
}
// (import ./umport.nix params)
