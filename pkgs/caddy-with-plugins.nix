{pkgs, ...}:
pkgs.caddy.withPlugins {
  plugins = ["github.com/caddy-dns/cloudflare@v0.2.3"];
  hash = "sha256-8E6OGxwZsjPofmfi1j8dMXTkCkIRxpzhQ/KTXYIGR0w=";
}
