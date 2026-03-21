{pkgs, ...}:
pkgs.caddy.withPlugins {
  plugins = ["github.com/caddy-dns/cloudflare@v0.2.3"];
  hash = "sha256-bL1cpMvDogD/pdVxGA8CAMEXazWpFDBiGBxG83SmXLA=";
}
