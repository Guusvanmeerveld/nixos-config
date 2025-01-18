{
  lib,
  config,
  ...
}: let
  cfg = config.custom.applications.shell.starship;
in {
  options = {
    custom.applications.shell.starship = {
      enable = lib.mkEnableOption "Enable Starship prompt";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;

      settings = let
        directory_color = "39";
        ssh_color = "180";
        cmd_duration_color = "101";
        time_color = "66";
      in {
        add_newline = false;

        git_branch.disabled = true;

        right_format = lib.concatStrings [
          "$cmd_duration"
          "$username"
          "$hostname"
          "$time"
        ];

        directory = {
          truncate_to_repo = false;
          style = "bold ${directory_color}";
          repo_root_style = "underline bold ${directory_color}";
          fish_style_pwd_dir_length = 2;
        };

        cmd_duration = {
          format = "[$duration](${cmd_duration_color}) ";
        };

        username = {
          format = "[$user@](${ssh_color})";
        };

        hostname = {
          format = "[$hostname](${ssh_color}) ";
        };

        time = {
          disabled = false;
          format = "[$time](${time_color})";
        };
      };
    };
  };
}
