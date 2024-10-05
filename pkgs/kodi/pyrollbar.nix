{
  lib,
  rel,
  buildKodiAddon,
  fetchzip,
  requests,
  kodi-six,
}:
buildKodiAddon rec {
  pname = "pyrollbar";
  namespace = "script.module.pyrollbar";
  version = "0.15.2";

  src = fetchzip {
    url = "https://mirrors.kodi.tv/addons/${lib.toLower rel}/${namespace}/${namespace}-${version}.zip";
    sha256 = "sha256-VALTfFJPF6abQscQkIvGEwtR8y1Ts/aXJe31v6wtTOw=";
  };

  propagatedBuildInputs = [kodi-six requests];

  meta = with lib; {
    homepage = "https://kodi.wiki/view/Add-on:Pyrollbar";
    description = "Python notifier for reporting exceptions, errors, and log messages to Rollbar.";
    license = licenses.mit;
  };
}
