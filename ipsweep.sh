#!/bin/bash

# Check if the IP prefix is given
if [ -z "$1" ]; then
    echo "Wrong Syntax"
    echo "No IP parameter was given"
    echo "Syntax Example:"
    echo "./ipsweep.sh 192.168.1"
    exit 1
fi

# Run the ping sweep
for ip in $(seq 1 254); do
    ping -c 1 "$1.$ip" | grep "64 bytes" | cut -d " " -f 4 | tr -d ":" &
done
wait # Wait for all background jobs to finish

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
        ping -c 1 "$1.$ip" | grep "64 bytes" | cut -d " " -f 4 | tr -d ":" >> "$filename" &
    done
    wait # Wait for all background jobs to finish

    # Get the full path of the file
    full_path=$(realpath "$filename")

    # Inform the user where the file is saved
    echo "File Saved As:"
    echo "$full_path"
fi
