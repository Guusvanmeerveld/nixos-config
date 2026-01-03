{pkgs, ...}:
pkgs.caddy.withPlugins {
  plugins = ["github.com/caddy-dns/cloudflare@v0.2.2"];
  hash = "sha256-dnhEjopeA0UiI+XVYHYpsjcEI6Y1Hacbi28hVKYQURg=";
}
