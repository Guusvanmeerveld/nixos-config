{
  buildDotnetModule,
  dotnetCorePackages,
  pkgs,
  fetchFromGitHub,
  buildNpmPackage,
  lib,
  ...
}: let
  qbittorrentClient = pkgs.callPackage ./qbittorrent {};
  transmissionClient = pkgs.callPackage ./transmission {};

  version = "2.9.3";

  src = fetchFromGitHub {
    owner = "cleanuparr";
    repo = "cleanuparr";
    tag = "v${version}";
    hash = "sha256-x3bwNMovtP4g40fRA6FpYW1kO4badlhvcl+HH145WBE=";
  };

  frontend = buildNpmPackage {
    pname = "Cleanuparr-Frontend";
    inherit version;

    src = "${src}/code/frontend";
    npmDepsHash = "sha256-lhhyLGLsl2hoQEBFilhti93wJUj17RoOvUl6EzDn+r4=";

    buildPhase = ''
      npm run build
    '';

    installPhase = ''
      mkdir -p $out
      cp -r dist/ui/browser $out/wwwroot
    '';

    meta = {
      description = "Cleanup system for *arr services";
      homepage = "https://cleanuparr.github.io/Cleanuparr/";
      license = lib.licenses.mit;
      mainProgram = "Cleanuparr";
    };
  };
in
  buildDotnetModule rec {
    pname = "Cleanuparr";

    inherit version src;

    dotnet-sdk = dotnetCorePackages.sdk_10_0;
    dotnet-runtime = dotnetCorePackages.runtime_10_0;

    buildInputs = [qbittorrentClient transmissionClient];

    postPatch = ''
      find code -type f -name "*.cs" -exec sed -i 's|AppContext.BaseDirectory|\"/var/lib/cleanuparr\"|g' {} +
    '';

    postInstall = ''
      mkdir -p $out
      cp -r  ${frontend}/wwwroot $out/wwwroot
    '';

    projectFile = [
      "code/backend/Cleanuparr.Api/Cleanuparr.Api.csproj"
    ];

    # enableParallelBuilding = false;
    selfContainedBuild = true;

    executables = ["Cleanuparr"];

    nugetDeps = ./deps.json;

    meta = {
      description = "Cleanup system for *arr services";
      homepage = "https://cleanuparr.github.io/Cleanuparr/";
      license = lib.licenses.mit;
      mainProgram = "Cleanuparr";
      inherit (dotnet-runtime.meta) platforms;
    };
  }
