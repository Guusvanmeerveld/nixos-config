{
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  ...
}:
buildDotnetModule rec {
  pname = "intro-skipper";

  version = "1.10.11.7";

  src = fetchFromGitHub {
    owner = "intro-skipper";
    repo = pname;
    tag = "10.11/v${version}";
    hash = "sha256-hl1OrnNPFkM5g1WYMVwCKdNLkNai0Vk7JBQ36vz5YCw=";
  };

  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.runtime_9_0;

  projectFile = "IntroSkipper.sln";
  nugetDeps = ./deps.json;

  postFixup = ''
    cp -r $out/lib/${pname}/* $out
    rm -r $out/lib
  '';
}
