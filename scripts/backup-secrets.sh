# shellcheck disable=SC2148

usage() {
    echo "Usage: $0 <backup|restore> <backup_location>"
    exit 1
}

# Check if the correct number of arguments is provided
if [ "$#" -lt 2 ]; then
   usage
fi

# Assign the first argument as the backup location
OPERATION="$1"
BACKUP_LOCATION="$2"

DIRS_TO_BACKUP=("$HOME/.ssh" "$HOME/.gnupg" "/secrets")

# Get the current date and time
CURRENT_DATE=$(date +"%Y%m%d_%H%M%S")
HOSTNAME=$(hostname)

backup() {
     # Check if the backup location exists, if not create it
    if [ ! -d "$BACKUP_LOCATION" ]; then
        echo "Backup location does not exist. Creating: $BACKUP_LOCATION"
        sudo mkdir -p "$BACKUP_LOCATION"
    fi

    # Create a tar file name with date, time, and hostname
    TAR_FILE="${BACKUP_LOCATION}/backup_${HOSTNAME}_${CURRENT_DATE}.tar.gz"

    # Create the backup
    sudo tar -czf "$TAR_FILE" "${DIRS_TO_BACKUP[@]}"

    # Check if the zip command was successful
    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        echo "Backup successful! Created: $TAR_FILE"
    else
        echo "Backup failed!"
        exit 1
    fi
}

restore() {
    # Find the most recent backup file in the backup location
    # shellcheck disable=SC2012
    BACKUP_FILE=$(ls -t created "$BACKUP_LOCATION"/backup_"$HOSTNAME"_*.tar.gz 2>/dev/null | head -n 1)

    # Check if a backup file was found
    if [ -z "$BACKUP_FILE" ]; then
        echo "No backup files found in: $BACKUP_LOCATION"
        exit 1
    fi

    echo "Restoring from the most recent backup: $BACKUP_FILE"

  
    # Extract the backup
    sudo tar -xzf "$BACKUP_FILE" -C /

    # Check if the tar command was successful
    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        echo "Restore successful! Files restored from: $BACKUP_FILE"
    else
        echo "Restore failed!"
        exit 1
    fi
}

sudo -v

# Perform the specified operation
case "$OPERATION" in
    backup)
        backup 
        ;;
    restore)
        restore
        ;;
    *)
        usage
        ;;
esac

