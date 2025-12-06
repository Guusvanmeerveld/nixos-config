{
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  ...
}:
buildDotnetModule rec {
  pname = "jellyfin-plugin-listenbrainz";

  version = "6.0.1.1";

  src = fetchFromGitHub {
    owner = "lyarenei";
    repo = pname;
    tag = version;
    hash = "sha256-voOdC5pnG22c3tOtOluRX6T+BSdfsSArMttOeyGTJZY=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  enableParallelBuilding = false;

  projectFile = "src/Jellyfin.Plugin.ListenBrainz/Jellyfin.Plugin.ListenBrainz.csproj";
  nugetDeps = ./deps.json;

  postFixup = ''
    cp -r $out/lib/${pname}/Jellyfin.Plugin.ListenBrainz.dll $out
  '';
}
