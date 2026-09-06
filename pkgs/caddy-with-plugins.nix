{pkgs, ...}:
pkgs.caddy.withPlugins {
  plugins = ["github.com/caddy-dns/cloudflare@v0.2.3"];
  hash = "sha256-9tO1blZoDhfxBbHMYsJzEWejuAuzM36/56dBR68dVKk=";
}
