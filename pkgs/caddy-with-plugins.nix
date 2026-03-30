{pkgs, ...}:
pkgs.caddy.withPlugins {
  plugins = ["github.com/caddy-dns/cloudflare@v0.2.3"];
  hash = "sha256-20o+14cn/eeLuf1c8uGE1ODRZGC0oxocaIVlv4tFSvA=";
}
