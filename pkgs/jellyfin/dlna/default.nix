{
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  ...
}:
buildDotnetModule rec {
  pname = "jellyfin-plugin-dlna";

  version = "10";

  src = fetchFromGitHub {
    owner = "jellyfin";
    repo = "jellyfin-plugin-dlna";
    tag = "v${version}";
    hash = "sha256-pPhMmH17RKktIX16ozSxsigxo6tU8tlST4IAm3vpjrw=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  projectFile = "Jellyfin.Plugin.Dlna.sln";
  nugetDeps = ./deps.json;
}
