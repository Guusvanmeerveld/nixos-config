{pkgs, ...}:
pkgs.caddy.withPlugins {
  plugins = ["github.com/caddy-dns/cloudflare@v0.2.3"];
  hash = "sha256-IJbMYNjWn0Mug/k4whdIwuKsxqaL/2rid8sypaEcsNw=";
}
