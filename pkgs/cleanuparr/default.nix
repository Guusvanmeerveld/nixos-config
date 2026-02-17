{
  buildDotnetModule,
  dotnetCorePackages,
  pkgs,
  inputs,
  lib,
  ...
}: let
  qbittorrentClient = pkgs.callPackage ./qbittorrent {};
  transmissionClient = pkgs.callPackage ./transmission {};
  frontend = pkgs.callPackage ./frontend.nix {inherit inputs;};
in
  buildDotnetModule rec {
    pname = "Cleanuparr";

    version = "2.6.1";

    src = inputs.cleanuparr;

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

    enableParallelBuilding = false;
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
