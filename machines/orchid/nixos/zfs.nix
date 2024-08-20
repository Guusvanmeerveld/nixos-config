{ pkgs, ... }: {
    config = {
        boot = {
            supportedFilesystems = [ "zfs" ];
            
            zfs = {
                forceImportRoot = false;
            };
        };

        services.zfs.autoScrub.enable = true;

        networking.hostId = "04ae0999";

        environment.systemPackages = with pkgs; [zfs];

        fileSystems."/mnt/data" = {
            device = "zpool/data";
            fsType = "zfs";
        };
    };
}