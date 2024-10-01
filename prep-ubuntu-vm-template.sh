#!/bin/bash

# Clean-up script for preparing a VM to be converted into a template
# This script should be run as root or with sudo privileges

# Exit immediately if a command exits with a non-zero status
set -e

# Function to print messages
print_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Function to check if the script is run as root
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo "This script must be run as root" 1>&2
        exit 1
    fi
}

# Clear command history
clear_history() {
    print_message "Clearing command history"
    history -c
    cat /dev/null > ~/.bash_history
    for user_home in /home/*; do
        cat /dev/null > "$user_home/.bash_history"
    done
}

# Remove temporary files
remove_temp_files() {
    print_message "Removing temporary files"
    rm -rf /tmp/*
    rm -rf /var/tmp/*
}

# Clear log files
clear_logs() {
    print_message "Clearing log files"
    find /var/log -type f -exec sh -c "cat /dev/null > {}" \;
}

# Remove machine-specific identifiers
remove_machine_id() {
    print_message "Removing machine-specific identifiers"
    truncate -s 0 /etc/machine-id
    rm -f /var/lib/dbus/machine-id
    ln -s /etc/machine-id /var/lib/dbus/machine-id
}

# Remove SSH host keys
remove_ssh_host_keys() {
    print_message "Removing SSH host keys"
    rm -f /etc/ssh/ssh_host_*
}

# Clear apt cache
clear_apt_cache() {
    print_message "Clearing apt cache"
    apt clean
}

# Remove user-specific caches
remove_user_caches() {
    print_message "Removing user-specific caches"
    rm -rf /home/*/.cache/*
    rm -rf /root/.cache/*
}

# Remove old kernels
remove_old_kernels() {
    print_message "Removing old kernels"
    apt autoremove --purge -y
}

# Clear systemd journal logs
clear_journal_logs() {
    print_message "Clearing systemd journal logs"
    journalctl --vacuum-time=1s
}

# Remove cloud-init logs and data
remove_cloud_init_data() {
    print_message "Removing cloud-init logs and data"
    rm -rf /var/lib/cloud/*
}

# Zero out free space
zero_free_space() {
    print_message "Zeroing out free space (this may take a while)"
    dd if=/dev/zero of=/EMPTY bs=1M
    rm -f /EMPTY
}

# Main function
main() {
    check_root
    print_message "Starting clean-up process"
    
    clear_history
    remove_temp_files
    clear_logs
    remove_machine_id
    remove_ssh_host_keys
    clear_apt_cache
    remove_user_caches
    remove_old_kernels
    clear_journal_logs
    remove_cloud_init_data
    zero_free_space
    
    print_message "Clean-up process completed"
    print_message "You can now shut down the VM and convert it to a template"
}

# Run the main function
main

# Clear the current shell history and exit
history -c
exit 0
