# shellcheck disable=SC2148

show_help() {
    echo "Usage: $0 <add|edit|rm> <FILE_NAME> <?USER>"
    exit 1
}

edit_file() {
    FILE=$1

    echo "Editing file..."

    sudo "$EDITOR" "$FILE"
}

COMMAND=$1
FILE_LOCATION=$2
USER=${3:-root}

if [[ -z $FILE_LOCATION ]]; then
    echo "File location not defined:"
    show_help
fi

FILE="/secrets/${FILE_LOCATION}"

case $COMMAND in
    "add")
        echo "Creating file..."
        sudo install -m 770 -g "$USER" -o "$USER" -D /dev/null "$FILE"

        edit_file "$FILE"
        ;;

    "edit")
        edit_file "$FILE"
        ;;

    "rm")
        sudo rm -r "$FILE"
        ;;
        
    *)
        echo "Invalid command:"
        show_help
        ;;
esac





