# Function to display the help page
display_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    printf "  -h, --help\t\tDisplay this help message\n"
    printf "  -u, --update\t\tUpdate the system\n"
    echo
    exit 0
}

ensure_latest() {
    # Check if the local repository exists
    if [ -d "$HMU_CONFIG_LOCATION/.git" ]; then
        echo "Repository exists. Pulling latest changes..."
        cd "$HMU_CONFIG_LOCATION" || exit
        git pull origin
    else
        echo "Repository does not exist. Cloning..."
        git clone "${HMU_REPO_URL}" "$HMU_CONFIG_LOCATION"
    fi
}

gui_update() {
    # Ask if we should update
    if zenity --question --text="Home Manager has an update available! Update now?" --title="Update"; then
        zenity --info --text="Downloading update..." --title="Updating" --no-wrap &

        LOADING_PID=$!  # Get the PID of the loading dialog

        cd "$HMU_CONFIG_LOCATION" || exit

        # Run the update command
        if home-manager build --flake "$HMU_CONFIG_LOCATION"; then
            nvd diff "$XDG_STATE_HOME/nix/profiles/home-manager/" result > "$HMU_CONFIG_LOCATION/nvd-output"

            kill $LOADING_PID

            zenity --text-info --filename "$HMU_CONFIG_LOCATION/nvd-output" --title "Update successful"

            if zenity --question --text "Switch to the new configuration now?" --title "Switch"; then
                home-manager switch --flake "$HMU_CONFIG_LOCATION"
            fi
        else
            kill $LOADING_PID
            zenity --error --text "Update failed" --title "Error"
        fi
    fi
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    
    case $key in
        -h|--help)
        display_help
        ;;

        -u|--update)
        shift
        ensure_latest
        gui_update
        exit 0
        ;;

        -c|--check)

        ;;

        *)
        echo "Unknown option: $1"
        display_help
        ;;
    esac
# shift
done

# If no arguments are provided, display the help page
display_help