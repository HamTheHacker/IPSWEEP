#!/bin/bash

# Function to display the help manual
function display_help() {
    echo -e "\e[1mIP SWEEP MANUAL\e[0m"
    echo "IP Sweep helps scan all IP addresses in a LAN."
    echo "Syntax:"
    echo "ipsweep <<IP Address>>"
    echo "For Example:"
    echo "ipsweep 192.168.1."
    echo "or"
    echo "ipsweep 192.168.1"
    echo
    echo "MAKE SURE TO ASK FOR PERMISSION. IT IS ILLEGAL IF PERMISSION WAS NOT GRANTED"
}

# Function to display user's IP information
function display_ip_info() {
    ip a
    echo "To scan other IPs, copy the first 3 octets of your IP. For example: 192.168.1"
    echo "Would you like to proceed to the next step? y[es] or n[o]"
    read proceed_answer
    if [[ $proceed_answer =~ ^[Yy][Ee][Ss]|[Yy]$ ]]; then
        echo "Type the first 3 octets from your IP:"
        read ip_prefix
        run_ipsweep "$ip_prefix"
    else
        echo "Exiting."
        exit 0
    fi
}

# Function to run the ipsweep
function run_ipsweep() {
    # Check if the IP prefix is given
    if [ -z "$1" ]; then
        echo "Wrong Syntax"
        echo "No IP parameter was given"
        echo "Syntax Example:"
        echo "./ipsweep.sh 192.168.1"
        exit 1
    fi

    # Initialize an array to store the responsive IPs
    declare -a responsive_ips

    # Run the ping sweep
    for ip in $(seq 1 254); do
        # Corrected the ping command to properly extract the IP address
        ping_output=$(ping -c 1 "$1.$ip" | grep "64 bytes from")
        if [ ! -z "$ping_output" ]; then
            ip_address=$(echo "$ping_output" | cut -d " " -f 4 | tr -d ":")
            responsive_ips+=("$ip_address")
            echo "$ip_address"
        fi &
    done
    wait # Wait for all background jobs to finish

    # Ask the user if they want to save the IPs
    echo "Would you like to store these IPs in a temporary file? y[es] or n[o]"
    read answer

    # Handle the user's decision to save IPs
    if [[ $answer =~ ^[Yy][Ee][Ss]|[Yy]$ ]]; then
        echo "Please name the text file:"
        read filename
        # Ensure the file is created and written to
        touch "$filename"
        for ip in "${responsive_ips[@]}"; do
            echo "$ip" >> "$filename"
        done
        full_path=$(realpath "$filename")
        echo "File Saved As:"
        echo "$full_path"
    fi

    # Ask the user if they want to scan the IPs with nmap
    echo "Would you like to scan these IPs into nmap? y[es] or n[o]"
    read nmap_answer

    # Handle the user's decision to use nmap
    if [[ $nmap_answer =~ ^[Yy][Ee][Ss]|[Yy]$ ]]; then
        # Correctly construct the nmap command with the IPs
        nmap_command="nmap -sV ${responsive_ips[*]}"
        echo "The nmap command line is:"
        echo "$nmap_command"
        echo "Would you like to execute this command line or paste it manually? e[xecute] or m[anual scan]"
        read execute_answer
        if [[ $execute_answer =~ ^[Xx][Ee][Cc][Uu][Tt][Ee]|[Xx]$ ]]; then
            # Execute the nmap command
            eval "$nmap_command"
        else
            echo "Please paste the command manually to execute the nmap scan."
            exit 0
        fi
    else
        echo "Exiting without scanning."
        exit 0
    fi
}

# Main menu
function main_menu() {
    clear
    echo -e "\e[1;31mIP SWEEP\e[0m"
    echo
    echo "Searching the digital wild for IP unicorns!"
    echo "Option 1: Scan your IP first to identify others' IP!"
    echo "Option 2: Scan others' IP Immediately!"
    echo "Option 3: Manual/ Help"
    echo "Option 4: Exit."
    echo "Press 1, 2, 3, or 4."
    read -p "Select an option: " option

    case $option in
        1)
            display_ip_info
            ;;
        2)
            echo "Type the first 3 octets from your IP:"
            read ip_prefix
            run_ipsweep "$ip_prefix"
            ;;
        3)
            display_help
            ;;
        4)
            echo "Exiting."
            exit 0
            ;;
        *)
            echo "Invalid option."
            main_menu
            ;;
    esac
}

# Check for no arguments and display the menu
if [ $# -eq 0 ]; then
    main_menu
else
    run_ipsweep "$1"
fi
