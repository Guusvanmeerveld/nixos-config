{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage (finalAttrs: {
  pname = "romm-frontend";
  version = "4.7.0";

  src = fetchFromGitHub {
    owner = "rommapp";
    repo = "romm";
    tag = finalAttrs.version;
    hash = "sha256-aw+TyPwpvQ5JqT3COE9dtBA37rwjGp23KFcA06qRBuc=";
  };

  sourceRoot = "${finalAttrs.src.name}/frontend";

  npmDepsHash = "sha256-cPLNVoRiKVO+K/FTQ/5UsBVmdReBIAOmLrHDIZFerpE=";

  makeCacheWritable = true;
  forceGitDeps = true;

  NODE_OPTIONS = "--max-old-space-size=4096";
  npmFlags = ["--legacy-peer-deps"];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r dist $out/
    runHook postInstall
  '';

  meta = {
    description = "A beautiful, powerful, self-hosted rom manager and player";
    homepage = "https://github.com/rommapp/romm";
    license = lib.licenses.agpl3Only;
    maintainers = [];
    platforms = lib.platforms.linux;
  };
})
