#!/bin/bash

# Detect Node directories and assign ports accordingly
node_dirs=(Node-*)
num_nodes=${#node_dirs[@]}

# Initialize base ports
http_base_port=22000
ws_base_port=32000
geth_base_port=30300

# Function to calculate ports for a specific node
calculate_ports() {
    local node_index="$1"
    local http_port=$((http_base_port + node_index))
    local ws_port=$((ws_base_port + node_index))
    local geth_port=$((geth_base_port + node_index))
    echo "$http_port $ws_port $geth_port"
}

# Loop through the detected Node directories and start Geth nodes
for ((i = 0; i < num_nodes; i++)); do
    node_dir="${node_dirs[$i]}"
    http_port_ws_port_geth_port=($(calculate_ports $i))
    http_port="${http_port_ws_port_geth_port[0]}"
    ws_port="${http_port_ws_port_geth_port[1]}"
    geth_port="${http_port_ws_port_geth_port[2]}"

    (
        cd "$node_dir" || exit
        export ADDRESS=$(grep -o '"address": *"[^"]*"' ./data/keystore/accountKeystore | grep -o '"[^"]*"$' | sed 's/"//g')
        export PRIVATE_CONFIG=ignore
        geth --datadir data \
            --networkid 1337 --nodiscover --verbosity 5 \
            --syncmode full \
            --istanbul.blockperiod 5 --mine --miner.threads 1 --miner.gasprice 0 --emitcheckpoints \
            --http --http.addr 127.0.0.1 --http.port "$http_port" --http.corsdomain "*" --http.vhosts "*" \
            --ws --ws.addr 127.0.0.1 --ws.port "$ws_port" --ws.origins "*" \
            --http.api admin,eth,debug,miner,net,txpool,personal,web3,istanbul \
            --ws.api admin,eth,debug,miner,net,txpool,personal,web3,istanbul \
            --unlock "${ADDRESS}" --allow-insecure-unlock --password ./data/keystore/accountPassword \
            --port "$geth_port" >/dev/null 2>&1
    ) &
    echo "Started $node_dir with HTTP port $http_port, WS port $ws_port, port $geth_port"
done