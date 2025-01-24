{lib, ...}: {
  options = {
    custom.virtualisation.docker.storage = {
      storageDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/lib";
      };
    };
  };
}
