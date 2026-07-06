{pkgs, ...}:
pkgs.caddy.withPlugins {
  plugins = ["github.com/caddy-dns/cloudflare@v0.2.3"];
  hash = "sha256-peY/XG37RC0e7FafJ3qNk53srtXZagxN/Hfexcc2TMM=";
}
