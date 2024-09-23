{
  lib,
  pkgs,
}:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "clipmon";
  version = "0.1.0";

  src = pkgs.fetchFromSourcehut {
    owner = "~whynothugo";
    repo = pname;
    rev = "697ea408c793211f0f698fe9fbdd8a84bb4a6f44";
    hash = "sha256-pEM9I/SvAcHVpz5qCuyr7Gtn8nnoTO1aEzvUL2xR5Vk=";
  };

  cargoHash = "sha256-arPf5UiVSRVbWXy34NFnzDh3oexMoDsRnnGDEBSIDms=";

  nativeBuildInputs = with pkgs; [
    makeWrapper
  ];

  buildInputs = with pkgs; [
    wayland
  ];

  postFixup = ''
    wrapProgram "$out/bin/clipmon" \
      --set LD_LIBRARY_PATH  ${pkgs.wayland}/lib
  '';

  meta = {
    description = "Clipboard monitor";
    homepage = "https://git.sr.ht/~whynothugo/clipmon";
    license = lib.licenses.isc;
    maintainers = [];

    mainProgram = "clipmon";
  };
}
