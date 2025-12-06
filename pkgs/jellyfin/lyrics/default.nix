{
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  ...
}:
buildDotnetModule rec {
  pname = "jellyfin-plugin-lyrics";

  version = "1.5";

  src = fetchFromGitHub {
    owner = "Felitendo";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-b8rsMMTvKv6Ttr2202Mn35xq+9KRCpFiiVifNhxlWEw=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  enableParallelBuilding = false;

  projectFile = "Jellyfin.Plugin.Lyrics/Jellyfin.Plugin.Lyrics.csproj";
  nugetDeps = ./deps.json;

  postFixup = ''
    cp -r $out/lib/${pname}/Jellyfin.Plugin.Lyrics.dll $out
  '';
}
