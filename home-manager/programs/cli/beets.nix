{
  lib,
  config,
  ...
}: let
  cfg = config.custom.programs.cli.beets;
in {
  options = {
    custom.programs.cli.beets = {
      enable = lib.mkEnableOption "Enable Beets, a music manager program";

      musicDirectory = lib.mkOption {
        type = lib.types.str;
        default = "~/Music";
        description = "The default directory where music will be stored";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    programs.beets = {
      enable = true;

      settings = {
        directory = cfg.musicDirectory;

        import = {
          move = true;
        };

        plugins = ["musicbrainz" "discogs" "deezer" "scrub" "fromfilename" "duplicates"];

        musicbrainz = {
          data_source_mismatch_penalty = 0.3; # Lower penalty = preferred
        };
      };
    };
  };
}
