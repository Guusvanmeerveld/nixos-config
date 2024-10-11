# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{pkgs, ...}: {
  imports = [
    ../../nixos/modules

    ./secrets.nix

    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  boot.tmp.cleanOnBoot = true;

  # zramSwap.enable = true;

  networking.hostName = "daisy";

  # Enable networking
  networking.networkmanager.enable = true;

  services.logind.extraConfig = ''
    RuntimeDirectorySize=2G
  '';

  # security.acme.acceptTerms = true;
  # security.acme.defaults.email = "security@guusvanmeerveld.dev";

  custom = {
    user = {
      name = "guus";
      authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDsTe0VL1j/6gHUUEM+ZBlsFKUZ9X7w/986R64hxcSrD guus@laptop"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCpr5+qSs4FRs0CRu2GX8lD/uETy4DgbVvYbukjerUvA61chVxkk3esm6KnWP4U9g0fM2UuU2RCcUFt4xPBJDmg4DzEBZrIcwthg3/LgGbTyxLsSvhLE7TIrZ59R8KL1ppD1d5c/2hoImXNccXFHW4TJ08ziSKS6h8GEpN8YOe6lLbTMaEDkMRm3bu2Z3NRDkyjHvjQ+rk76cv4IUgWnDVOnw1owzOd2uIjJRc+gmGXFaO77l2pqib9NAUKERNq/K0Q0zXTeKNf/zBpsE2/GTxa3zZN2Iylqac/1ZVE6B+U8RhFOulK95vPiJZyXsMpbiVsIbhTXcx3xqPnQD5gH6N8AvkiMV6nRlUAWvNI4Pflm0GMKLMq3CSKJjCFDDoc0ZYYw2aIBzH2dU1lZ/NO4S6pN7sEQWwFtWeuY2trIgYl75lAXwds9aKKtNC2/6C24qr6S8PCba7EkCLZxgWyuADvuIe/lAWFLrUUC9qkG/bcbhxcCMa6DjzPLa1H6+fBJ20= guus@desktop"
      ];
    };

    applications = {
      shell.zsh.enable = true;

      services = {
        docker = {
          enable = true;

          watchtower.enable = true;

          searxng = {
            enable = true;

            externalDomain = "https://search.guusvanmeerveld.dev";
          };

          caddy = {
            enable = true;

            openFirewall = true;

            caddyFile = pkgs.writeText "Caddyfile" ''
              {
              	admin off
              }

              search.guusvanmeerveld.dev {
              	@api {
              		path /config
              		path /healthz
              		path /stats/errors
              		path /stats/checker
              	}

              	@static {
              		path /static/*
              	}

              	@notstatic {
              		not path /static/*
              	}

              	@imageproxy {
              		path /image_proxy
              	}

              	@notimageproxy {
              		not path /image_proxy
              	}

              	header {
              		# Enable HTTP Strict Transport Security (HSTS) to force clients to always connect via HTTPS
              		Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"

              		# Enable cross-site filter (XSS) and tell browser to block detected attacks
              		X-XSS-Protection "1; mode=block"

              		# Prevent some browsers from MIME-sniffing a response away from the declared Content-Type
              		X-Content-Type-Options "nosniff"

              		# Disable some features
              		Permissions-Policy "accelerometer=(),ambient-light-sensor=(),autoplay=(),camera=(),encrypted-media=(),focus-without-user-activation=(),geolocation=(),gyroscope=(),magnetometer=(),microphone=(),midi=(),payment=(),picture-in-picture=(),speaker=(),sync-xhr=(),usb=(),vr=()"

              		# Disable some features (legacy)
              		Feature-Policy "accelerometer 'none';ambient-light-sensor 'none'; autoplay 'none';camera 'none';encrypted-media 'none';focus-without-user-activation 'none'; geolocation 'none';gyroscope 'none';magnetometer 'none';microphone 'none';midi 'none';payment 'none';picture-in-picture 'none'; speaker 'none';sync-xhr 'none';usb 'none';vr 'none'"

              		# Referer
              		Referrer-Policy "no-referrer"

              		# X-Robots-Tag
              		X-Robots-Tag "noindex, noarchive, nofollow"

              		# Remove Server header
              		-Server
              	}

              	header @api {
              		Access-Control-Allow-Methods "GET, OPTIONS"
              		Access-Control-Allow-Origin  "*"
              	}

              	# Cache
              	header @static {
              		# Cache
              		Cache-Control "public, max-age=31536000"
              		defer
              	}

              	header @notstatic {
              		# No Cache
              		Cache-Control "no-cache, no-store"
              		Pragma "no-cache"
              	}

              	# CSP (see http://content-security-policy.com/ )
              	header @imageproxy {
              		Content-Security-Policy "default-src 'none'; img-src 'self' data:"
              	}

              	header @notimageproxy {
              		Content-Security-Policy "upgrade-insecure-requests; default-src 'none'; script-src 'self'; style-src 'self' 'unsafe-inline'; form-action 'self' https://github.com/searxng/searxng/issues/new; font-src 'self'; frame-ancestors 'self'; base-uri 'self'; connect-src 'self' https://overpass-api.de; img-src 'self' data: https://*.tile.openstreetmap.org; frame-src https://www.youtube-nocookie.com https://player.vimeo.com https://www.dailymotion.com https://www.deezer.com https://www.mixcloud.com https://w.soundcloud.com https://embed.spotify.com"
              	}

              	# SearXNG
              	handle {
              		encode zstd gzip

              		reverse_proxy searxng:8080 {
              			header_up X-Forwarded-Port {http.request.port}
              			header_up X-Forwarded-Proto {http.request.scheme}
              			header_up X-Real-IP {remote_host}
              		}
              	}
              }
            '';
          };
        };

        openssh.enable = true;
        fail2ban.enable = true;
      };
    };
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
