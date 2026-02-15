{
  buildNpmPackage,
  inputs,
  lib,
  ...
}:
buildNpmPackage {
  pname = "Cleanuparr-Frontend";
  version = "2.6.1";
  src = "${inputs.cleanuparr}/code/frontend";
  npmDepsHash = "sha256-vONOxAptlYyrXxEVsnHT3oKjvwtuiPf+SicjQZlnZoY=";

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
}
