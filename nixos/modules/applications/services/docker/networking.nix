{lib, ...}: {
  options = {
    custom.applications.services.docker.networking = {
      defaultNetworkName = lib.mkOption {
        type = lib.types.str;
        default = "internet";
      };
    };
  };
}
