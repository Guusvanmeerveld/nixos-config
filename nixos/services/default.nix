{...}: {
  imports = [
    ./searx.nix
    ./nginx.nix
    ./radicale.nix
    ./miniflux.nix
    ./vaultwarden.nix
    ./invidious.nix
    ./syncthing.nix
    ./minecraft.nix
    ./openssh.nix
    ./fail2ban.nix
    ./dnsmasq.nix
    ./samba
    ./gamemode.nix
    ./sunshine.nix
    ./gvfs.nix
    ./motd.nix
    ./kdeconnect.nix
    ./autoupgrade.nix
    ./caddy.nix
    ./qbittorrent.nix
    ./radarr.nix
    ./sonarr.nix
    ./prowlarr.nix
    # ./jellyfin.nix
  ];
}
