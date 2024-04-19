#!/bin/bash

# Define the process name to search for
process_name="geth --datadir data"

# Function to stop Geth nodes
stop_geth_nodes() {
    pkill -f "$process_name"
}

# Call the function to stop the Geth nodes
stop_geth_nodes

echo "Stopped all Quorum nodes."