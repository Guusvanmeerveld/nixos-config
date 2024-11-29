{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.custom.applications.services.updater;

  configLocation = "/tmp/home-manager-updater";

  updateSourceCodeScript = pkgs.writeShellApplication {
    name = "home-manager-update-source";

    runtimeInputs = with pkgs; [git];

    text = ''
      # Check if the local repository exists
      if [ -d "${configLocation}/.git" ]; then
          echo "Repository exists. Pulling latest changes..."
          cd "${configLocation}" || exit
          git pull origin
      else
          echo "Repository does not exist. Cloning..."
          git clone "${cfg.repoUrl}" "${configLocation}"
      fi
    '';
  };

  guiUpdaterScript = pkgs.writeShellApplication {
    name = "home-manager-updater-gui";

    runtimeInputs = with pkgs; [gnome.zenity home-manager nix git nvd];

    text = ''
      # Ask if we should update
      if zenity --question --text="Home Manager has an update available! Update now?" --title="Update"; then
        zenity --info --text="Downloading update..." --title="Updating" --no-wrap &
        LOADING_PID=$!  # Get the PID of the loading dialog

        cd ${configLocation}

        # Run the update command
        if home-manager build --flake ${configLocation}; then
          nvd diff ${config.xdg.stateHome}/nix/profiles/home-manager/ result > ${configLocation}/nvd-output

          kill $LOADING_PID

          zenity --text-info --filename ${configLocation}/nvd-output --title "Update successful"

          if zenity --question --text "Switch to the new configuration now?" --title "Switch"; then
            home-manager switch --flake ${configLocation}
          fi
        else
          kill $LOADING_PID
          zenity --error --text "Update failed" --title "Error"
        fi
      fi
    '';
  };

  updaterScript = pkgs.writeShellApplication {
    name = "home-manager-updater";

    runtimeInputs = [guiUpdaterScript updateSourceCodeScript];

    text = ''
      home-manager-update-source
      home-manager-updater-gui
    '';
  };
in {
  options = {
    custom.applications.services.updater = {
      enable = lib.mkEnableOption "Enable Home-Manager updating service";

      repoUrl = lib.mkOption {
        type = lib.types.str;

        default = "https://github.com/guusvanmeerveld/nixos-config";
      };

      schedule = lib.mkOption {
        type = lib.types.str;
        default = "daily";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user = {
      timers."home-manager-updater" = {
        Unit = {
          Description = "Timer for Home-Manager updating service";
        };

        Timer = {
          Persistent = true;
          OnCalendar = cfg.schedule;
        };

        Install = {
          WantedBy = ["timers.target"];
        };
      };

      services."home-manager-updater" = {
        Service = {
          Type = "oneshot";
          ExecStart = lib.getExe updaterScript;
        };
      };
    };
  };
}
