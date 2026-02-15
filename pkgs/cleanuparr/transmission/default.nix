{
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  ...
}:
buildDotnetModule rec {
  pname = "transmission-net-client";

  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "Cleanuparr";
    repo = "Transmission.API.RPC";
    rev = "1d2548c3c888a2d8b0a2bf4fbefe2f91e981e263";
    hash = "sha256-JFmTyRzHN3fDdZOoeFz89fk7kroT33tceoUpVBoWS5g=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  projectFile = "Transmission.API.RPC/Transmission.API.RPC.csproj";

  nugetDeps = ./deps.json;

  packNupkg = true;
}
