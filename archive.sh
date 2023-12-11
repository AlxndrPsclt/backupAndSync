#!/bin/sh

# Configuration
CONFIG_FILE="config.yml"

# Function to read value from YAML file
read_yaml() {
    yq e ".$1" $CONFIG_FILE
}

# Function to add file to IPFS
add_to_ipfs() {
    FILENAME=$1
    OUTPUT_FILE="@${FILENAME}"
    IPFS_NODE=$(read_yaml "ipfs.node_add_address")

    # Add file to IPFS using HTTP API
    RESPONSE=$(curl -s -X POST -F file=@$FILENAME $IPFS_NODE/api/v0/add)

    echo $RESPONSE

    # Check if the response contains a valid CID
    CID=$(echo $RESPONSE | cut -d '"' -f 8)
    if [ -z "$CID" ] || [ "$CID" = "null" ]; then
        echo "Error: File addition to IPFS failed."
        exit 1
    fi

    # Save CID to a file and remove the original file
    echo $CID > $OUTPUT_FILE
    rm $FILENAME
    echo "File added and original file removed. CID: $CID"
}

# Main script
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 filename.ext"
    exit 1
fi

FILENAME=$1

# Check if the filename starts with '@'
if [ "${FILENAME#@}" = "$FILENAME" ]; then
    add_to_ipfs $FILENAME
else
    echo "Filename starts with @. Skipping."
fi
