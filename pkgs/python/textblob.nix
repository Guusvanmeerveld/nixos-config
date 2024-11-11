{ pkgs }: pkgs.python311.pkgs.buildPythonPackage
    rec {
    pname = "textblob";
    version = "0.7.0";
    format = "pyproject";

    nativeBuildInputs = with pkgs; [
        python311.pkgs.flit-core
        pkg-config
    ];

    src = pkgs.fetchFromGitHub {
        owner = "sloria";
        repo = "TextBlob";
        rev = "24e2ec26133bd42542a3685dcefe0efeff327162";
        hash = "sha256-7bBc4oCrfee+/5tUT+0gkRRkNAJms5izfRRIv1pXJWs=";
    };
}