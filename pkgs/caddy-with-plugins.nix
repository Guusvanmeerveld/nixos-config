{pkgs, ...}:
pkgs.caddy.withPlugins {
  plugins = ["github.com/caddy-dns/cloudflare@v0.2.3"];
  hash = "sha256-LEpsjwy0CYx04cg42CfG6/sFv86kHmhezUG6yGedYcA=";
}
