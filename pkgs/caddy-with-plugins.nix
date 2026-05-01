{pkgs, ...}:
pkgs.caddy.withPlugins {
  plugins = ["github.com/caddy-dns/cloudflare@v0.2.3"];
  hash = "sha256-+htYZclHv9qI0TeHcBFvPkWzJVAZ5jqzTODrh4YmqXY=";
}
