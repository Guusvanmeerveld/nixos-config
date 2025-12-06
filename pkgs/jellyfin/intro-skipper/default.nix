{
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  ...
}:
buildDotnetModule rec {
  pname = "intro-skipper";

  version = "1.10.11.9";

  src = fetchFromGitHub {
    owner = "intro-skipper";
    repo = pname;
    tag = "10.11/v${version}";
    hash = "sha256-j4Q90QAPA3Np0tmp7IVumQwCoKRKeXqW0cFltSlkIJ4=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  enableParallelBuilding = false;

  projectFile = "IntroSkipper/IntroSkipper.csproj";
  nugetDeps = ./deps.json;

  postFixup = ''
    cp -r $out/lib/${pname}/IntroSkipper.dll $out
  '';
}
