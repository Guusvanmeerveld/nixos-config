{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.office.latex;
in {
  options = {
    custom.programs.office.latex = {
      enable = lib.mkEnableOption "Enable Latex";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.texlive = {
      enable = true;

      extraPackages = tpkgs: {
        inherit
          (tpkgs)
          collection-basic
          collection-latexrecommended
          collection-fontsrecommended
          latexmk
          latexindent
          ;
      };
    };
  };
}
