#!/bin/sh

# Configuration
CONFIG_FILE="config.yml"

# Function to read value from YAML file
read_yaml() {
    yq e ".$1" $CONFIG_FILE
}

# Function to download file from IPFS
download_from_ipfs() {
    CID_FILE=$1
    FILENAME=${CID_FILE#@}
    IPFS_NODE=$(read_yaml "ipfs.node_get_address")

    # Read CID from file
    CID=$(cat $CID_FILE)

    # Download file from IPFS using wget
    curl -L "http://localhost:8080/ipfs/$CID" -o "$FILENAME"

    # Check if the download was successful
    if [ $? -ne 0 ]; then
        echo "Error: File download from IPFS failed."
        exit 1
    fi

    # Remove CID file
    rm $CID_FILE
    echo "File downloaded from IPFS and CID file removed."
}

# Main script
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 @filename.ext"
    exit 1
fi

FILENAME=$1

# Check if the filename starts with '@'
if [ "${FILENAME#@}" != "$FILENAME" ]; then
    download_from_ipfs $FILENAME
else
    echo "Error: Filename does not start with @."
fi

