{
  buildNpmPackage,
  fetchFromGitHub,
  jq,
  lib,
  ...
}:
buildNpmPackage (let
  binName = "free-epic-games";
in {
  pname = "free-epic-games";
  version = "5.1.0";

  src = fetchFromGitHub {
    owner = "claabs";
    repo = "epicgames-freegames-node";
    rev = "40ef654990ad639cf3d13dd1c9c4db2f1e5ecb79";
    hash = "sha256-FDNtZjqWusBbtHmPUXrqNR4G/WwKNmRYhV0SGw4IkZ0=";
  };

  npmDepsHash = "sha256-y/TfbYKkjzBmigV3/KwuHVh5j21MCOsOyn/L9y5UrnU=";

  postPatch = ''
    mv package.json 2.json
    ${lib.getExe jq} '. + {"bin":{"${binName}":"dist/src/index.js"}}' -rS 2.json > package.json
  '';

  env = {
    PUPPETEER_SKIP_DOWNLOAD = true;
  };

  meta = {
    description = "Automatically login and find available free games the Epic Games Store. Sends you a prepopulated checkout link so you can complete the checkout after logging in. Supports multiple accounts, login sessions, and scheduled runs. ";
    homepage = "https://github.com/claabs/epicgames-freegames-node";
    mainProgram = binName;
    license = lib.licenses.mit;
  };
})
