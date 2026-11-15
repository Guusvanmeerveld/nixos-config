{pkgs, ...}:
pkgs.caddy.withPlugins {
  plugins = ["github.com/caddy-dns/cloudflare@v0.2.3"];
  hash = "sha256-OIQoJ+Q7rfJkoy/H01L2lEDysOlYzl63s6pOrSj9LlQ=";
}
