{
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  ...
}:
buildDotnetModule rec {
  pname = "jellyfin-plugin-trakt";

  version = "27";

  src = fetchFromGitHub {
    owner = "jellyfin";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-T4T+0ZsOcNxZHk/TzCTH7gpQz8pvSWGyJ0l7XESPu+c=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  enableParallelBuilding = false;

  projectFile = "Trakt/Trakt.csproj";
  nugetDeps = ./deps.json;

  postFixup = ''
    cp -r $out/lib/${pname}/Trakt.dll $out
  '';
}
