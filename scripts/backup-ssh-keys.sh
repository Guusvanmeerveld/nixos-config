# Function to display usage
usage() {
    echo "Usage: $0 <mount_point> [backup|restore]"
    echo "  <mount_point> - The mount point of the external USB drive"
    echo "  backup        - Backup SSH keys to the external USB drive"
    echo "  restore       - Restore SSH keys from the external USB drive"
    exit 1
}

# Function to backup SSH keys
backup_keys() {
    local archive_name="$1"
    
    tar -czf "$archive_name" -C ~/.ssh .  # Create a tar.gz archive of the .ssh directory

    echo "Backup completed successfully to $archive_name"
}

# Function to restore SSH keys
restore_keys() {
    local backup_dir="$1"
    local hostname="$2"

    local archive_name=$(ls -t "$backup_dir"/backup-$hostname-*.tar.gz 2>/dev/null | head -n 1)

    tar -xzf "$archive_name" -C ~/.ssh  # Extract the tar.gz archive to the .ssh directory

    echo "Restore completed successfully from $archive_name"
}

# Check if the user provided the correct number of arguments
if [ $# -ne 2 ]; then
    usage
fi

# Process the command
usb_mount_point="$1"

if [ ! -d "$usb_mount_point" ]; then
    echo "Error: USB drive is not mounted at $usb_mount_point"
    exit 1
fi

backup_dir="$usb_mount_point/ssh-backups"

hostname=$(hostname)
current_date=$(date +%Y-%m-%d)
archive_name="$backup_dir/backup-$hostname-$current_date.tar.gz"

case $2 in
    backup)
        # Check if the user has write permissions on the USB mount point
        if [ ! -w "$usb_mount_point" ]; then
            echo "Error: You do not have write permissions on $usb_mount_point"
            exit 1
        fi

        mkdir -p "$backup_dir"

        # Backup the script itself to the drive.
        cp $0 $backup_dir/backup-ssh-keys.sh

        backup_keys "$archive_name"
        ;;

    restore)
        restore_keys "$backup_dir" "$hostname"
        ;;

    *)
        usage
        ;;
esac
