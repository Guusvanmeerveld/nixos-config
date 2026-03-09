{
  nodejs_22,
  pnpm_10,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  sqlite,
  python3,
  python3Packages,
  makeWrapper,
  pnpmConfigHook,
  lib,
  nixosTests,
  nix-update-script,
  ...
}: let
  nodejs = nodejs_22;
  pnpm = pnpm_10.override {inherit nodejs;};
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "seerr";
    version = "3.1.0";

    src = fetchFromGitHub {
      owner = "seerr-team";
      repo = "seerr";
      tag = "v${finalAttrs.version}";
      hash = "sha256-POmxXuuxATWyNLnKKNO7W3BZ1WL0t0/0IoOpzqKs4oQ=";
    };

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      inherit pnpm;
      fetcherVersion = 1;
      hash = "sha256-J4SZBM5oKIKGLDKDquBhMdW/BtrDygTPZYzJe5evlOo=";
    };

    buildInputs = [sqlite];

    nativeBuildInputs = [
      python3
      python3Packages.distutils
      nodejs
      makeWrapper
      pnpmConfigHook
      pnpm
    ];

    preBuild = ''
      export npm_config_nodedir=${nodejs}
      pushd node_modules
      pnpm rebuild bcrypt sqlite3
      popd
    '';

    buildPhase = ''
      runHook preBuild

      pnpm build
      CI=true pnpm prune --prod --ignore-scripts
      rm -rf .next/cache

      # Clean up broken symlinks left behind by `pnpm prune`
      # https://github.com/pnpm/pnpm/issues/3645
      find node_modules -xtype l -delete

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share
      cp -r -t $out/share .next node_modules dist public package.json seerr-api.yml
      runHook postInstall
    '';

    postInstall = ''
      mkdir -p $out/bin
      makeWrapper '${nodejs}/bin/node' "$out/bin/seerr" \
        --add-flags "$out/share/dist/index.js" \
        --chdir "$out/share" \
        --set NODE_ENV production
    '';

    passthru = {
      inherit (nixosTests) jellyseerr;
      updateScript = nix-update-script {};
    };

    meta = {
      description = "Open-source media request and discovery manager for Jellyfin, Plex, and Emby.";
      homepage = "https://github.com/seerr-team/seerr";
      longDescription = ''
        Seerr is a free and open source software application for managing requests for your media library. It integrates with the media server of your choice: Jellyfin, Plex, and Emby. In addition, it integrates with your existing services, such as Sonarr, Radarr.
      '';
      license = lib.licenses.mit;
      maintainers = [];
      platforms = lib.platforms.linux;
      mainProgram = "seerr";
    };
  })
