{
  lib,
  buildKodiAddon,
  fetchFromGitHub,
  requests,
  pyrollbar,
}:
buildKodiAddon rec {
  pname = "hue-service";
  namespace = "script.service.hue";
  version = "2.0.10";

  src = fetchFromGitHub {
    owner = "zim514";
    repo = "script.service.hue";
    rev = "v${version}";
    sha256 = "sha256-JrCGDNvkj1NI3NqH1DqC73/aqVZnhY2fwX/3HZg4qi8=";
  };

  propagatedBuildInputs = [
    requests
    pyrollbar
  ];

  meta = with lib; {
    homepage = "https://github.com/zim514/script.service.hue";
    description = "Kodi add-on for Philips Hue.";
    license = licenses.mit;
  };
}
