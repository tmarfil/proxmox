#!/bin/bash

# Script to check status of Proxmox integration services
# This script should be run with sudo privileges

# Set color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check service status
check_service() {
    local service_name=$1
    echo -n "Checking $service_name: "
    if systemctl is-active --quiet $service_name; then
        echo -e "${GREEN}RUNNING${NC}"
    else
        echo -e "${RED}NOT RUNNING${NC}"
    fi
    echo "  Enabled: $(systemctl is-enabled --quiet $service_name && echo 'Yes' || echo 'No')"
    echo "  Status:"
    systemctl status $service_name --no-pager | sed 's/^/    /'
    echo
}

# Function to check if a package is installed
check_package() {
    local package_name=$1
    echo -n "Checking if $package_name is installed: "
    if dpkg -s $package_name &> /dev/null; then
        echo -e "${GREEN}INSTALLED${NC}"
    else
        echo -e "${RED}NOT INSTALLED${NC}"
    fi
}

# Main function
main() {
    echo "Checking Proxmox integration services status:"
    echo "============================================"
    
    # Check QEMU Guest Agent
    check_package "qemu-guest-agent"
    check_service "qemu-guest-agent"
    
    # Check SPICE Agent
    check_package "spice-vdagent"
    check_service "spice-vdagent"
    
    # Check ACPI Daemon
    check_package "acpid"
    check_service "acpid"
    
    # Check Open VM Tools
    check_package "open-vm-tools"
    check_service "open-vm-tools"
    
    # Check Chrony (for time synchronization)
    check_package "chrony"
    check_service "chronyd"
    
    # Additional Proxmox-related checks
    echo "Additional Checks:"
    echo "=================="
    
    # Check if virtio drivers are loaded
    echo "Checking virtio drivers:"
    lsmod | grep virtio | sed 's/^/  /'
    echo
    
    # Check if /dev/pve exists (indicates Proxmox environment)
    echo -n "Checking for /dev/pve: "
    if [ -e /dev/pve ]; then
        echo -e "${GREEN}EXISTS${NC}"
    else
        echo -e "${RED}DOES NOT EXIST${NC}"
    fi
    echo
    
    # Check TCP BBR status
    echo "TCP BBR Status:"
    sysctl net.ipv4.tcp_congestion_control | sed 's/^/  /'
    echo
}

# Run the main function
main
