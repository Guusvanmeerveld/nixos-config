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

  version = "2.10.5";

  src = fetchFromGitHub {
    owner = "cleanuparr";
    repo = "cleanuparr";
    tag = "v${version}";
    hash = "sha256-jaBAT3DWbsE5upQD4rERUVW/sb5Hu8pyuY7RdvhVDMs=";
  };

  frontend = buildNpmPackage {
    pname = "Cleanuparr-Frontend";
    inherit version;

    src = "${src}/code/frontend";
    npmDepsHash = "sha256-HVA869ahw3PS9/a9JLhHS8KieioHAdRYjp2U47WcmVU=";

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
