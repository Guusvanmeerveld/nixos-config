{
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  ...
}:
buildDotnetModule rec {
  pname = "qbittorrent-net-client";

  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "Cleanuparr";
    repo = pname;
    rev = "259d1c19e783a994345b9abf6afbbc6a39d82cf7";
    hash = "sha256-3jBoVt1J+dI1AxD4/FYrhjrwR4aLElwF6B59hxVbhu8=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  projectFile = "src/QBittorrent.Client/QBittorrent.Client.csproj";

  enableParallelBuilding = false;

  nugetDeps = ./deps.json;

  packNupkg = true;
}
