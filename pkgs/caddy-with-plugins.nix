{pkgs, ...}:
pkgs.caddy.withPlugins {
  plugins = ["github.com/caddy-dns/cloudflare@v0.2.3"];
  hash = "sha256-4Y3JgKVCpB5BD9bh3g3Q70o/hbK7uU53QUR1meu+EeA=";
}
