#!/bin/bash

# Function to display the help manual
function display_help() {
    echo -e "\e[1mIP SWEEP MANUAL\e[0m"
    echo "IP Sweep helps scan all IP addresses in a LAN."
    echo "Syntax:"
    echo "ipsweep <IP Address>"
    echo "For Example:"
    echo "ipsweep 192.168.1"
    echo
    echo "MAKE SURE TO ASK FOR PERMISSION. IT IS ILLEGAL IF PERMISSION WAS NOT GRANTED"
}

# Function to run the ipsweep
function run_ipsweep() {
    for ip in $(seq 1 254); do
        ping -c 1 -W 1 "$1.$ip" | grep "64 bytes" | cut -d " " -f 4 | tr -d ":" &
    done
    wait # Wait for all background jobs to finish
}

# Main program
if [[ "$1" == "-h" || "$1" == "man" || "$1" == "help" ]]; then
    display_help
    exit 0
elif [ -z "$1" ]; then
    echo "WELCOME TO IPSWEEP"
    echo -e "\n\n\n\nLoading..."
    sleep 3
    echo "Scan first 3 octets from your IP to get IPs from the same LAN:"
    read ip_prefix
    run_ipsweep "$ip_prefix"
else
    run_ipsweep "$1"
fi

# Ask the user if they want to save the IPs
echo "Would you like to store these IPs in a temporary file? y[es] or n[o]"
read answer

# Handle the user's decision
if [[ $answer =~ ^[Nn][Oo]?$ ]]; then
    echo "Exiting without saving."
    exit 0
elif [[ $answer =~ ^[Yy][Ee][Ss]|[Yy]$ ]]; then
    echo "Please name the text file:"
    read filename
    # Save the IPs to the file
    for ip in $(seq 1 254); do
        ping -c 1 "$1.$ip" | grep "64 bytes" | cut -d " " -
