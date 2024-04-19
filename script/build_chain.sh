#!/bin/bash
# This script is used to build a simple and private IBFT network using quorum. 

# create the IBFT-Network directory needed for establishing a IBFT network
IBFTNetwork_PATH="/home/IBFT-Network"
if [ ! -d "$IBFTNetwork_PATH" ]; then
  # Create directory
  mkdir -p "$IBFTNetwork_PATH/Node-0/data/keystore"
  mkdir -p "$IBFTNetwork_PATH/Node-1/data/keystore"
  mkdir -p "$IBFTNetwork_PATH/Node-2/data/keystore"
  mkdir -p "$IBFTNetwork_PATH/Node-3/data/keystore"
  mkdir -p "$IBFTNetwork_PATH/Node-4/data/keystore"
  echo "IBFT-Network created at $IBFTNetwork_PATH"
else
  echo "IBFT-Network already exists at $IBFTNetwork_PATH"
fi

FILE_PATH="/home/IBFT-Network/artifacts"
NODE_PATH="/home/IBFT-Network"

# remove old files if they exist
if [ -d "$FILE_PATH" ]; then
    rm -rf "$FILE_PATH"
    echo "artifacts has been deleted."
else
    echo "artifacts does not exist."
fi

# create new artifacts
cd $NODE_PATH
npx quorum-genesis-tool --consensus ibft --chainID 1337 --blockperiod 5 --requestTimeout 10 --epochLength 30000 --difficulty 1 --gasLimit '0xFFFFFF' --coinbase '0x0000000000000000000000000000000000000000' --validators 5 --members 0 --bootnodes 0 --outputPath 'artifacts'
echo "a new artifacts has been created."

cd $FILE_PATH
newest_file=$(ls -t $FILE_PATH | head -n 1)
echo "The most recently created file is: $newest_file"

mv $FILE_PATH/$newest_file/* $FILE_PATH
echo "It has been moved to artifacts folder."

# copy new files to all nodes
cd $FILE_PATH/goQuorum
JSON_FILE="static-nodes.json"
TEMP_FILE="temp.json"
if [ -f "$JSON_FILE" ]; then
    touch $TEMP_FILE
    echo "generate temp.json successfully"
    if [ -f "$TEMP_FILE" ]; then
        echo "static-nodes.json and temp.json do exist."
        replace=30300
        while IFS= read -r line
        do
            if [[ $line == *"<HOST>:30303"* ]]; then
                line=$(echo "$line" | sed "s/<HOST>:30303/127.0.0.1:$replace/g")
                ((replace++))
                # replace=$((replace+1))
            fi
            echo "$line" >> $TEMP_FILE
        done < "$JSON_FILE"

        echo "]" >> $TEMP_FILE
        mv $TEMP_FILE $JSON_FILE
    fi
else
    echo "static-nodes.json does not exist."
fi

cd $FILE_PATH/goQuorum
cp static-nodes.json genesis.json $NODE_PATH/Node-0/data/
cp static-nodes.json genesis.json $NODE_PATH/Node-1/data/
cp static-nodes.json genesis.json $NODE_PATH/Node-2/data/
cp static-nodes.json genesis.json $NODE_PATH/Node-3/data/
cp static-nodes.json genesis.json $NODE_PATH/Node-4/data/
echo "static-nodes.json and genesis.json have been copied to all nodes"

cd $FILE_PATH/validator0
cp nodekey* address ../../Node-0/data
cp account* ../../Node-0/data/keystore
cd $FILE_PATH/validator1
cp nodekey* address ../../Node-1/data
cp account* ../../Node-1/data/keystore
cd $FILE_PATH/validator2
cp nodekey* address ../../Node-2/data
cp account* ../../Node-2/data/keystore
cd $FILE_PATH/validator3
cp nodekey* address ../../Node-3/data
cp account* ../../Node-3/data/keystore
cd $FILE_PATH/validator4
cp nodekey* address ../../Node-4/data
cp account* ../../Node-4/data/keystore
echo "account*, nodekey* and address have been copied to all nodes"

# initialize all nodes
if [ -d "$NODE_PATH/Node-0/data/geth" ]; then
    rm -rf "$NODE_PATH/Node-0/data/geth"
    echo "The geth file in Node-0 has been deleted."
fi
if [ -d "$NODE_PATH/Node-1/data/geth" ]; then
    rm -rf "$NODE_PATH/Node-1/data/geth"
    echo "The geth file in Node-1 has been deleted."
fi
if [ -d "$NODE_PATH/Node-2/data/geth" ]; then
    rm -rf "$NODE_PATH/Node-2/data/geth"
    echo "The geth file in Node-2 has been deleted."
fi
if [ -d "$NODE_PATH/Node-3/data/geth" ]; then
    rm -rf "$NODE_PATH/Node-3/data/geth"
    echo "The geth file in Node-3 has been deleted."
fi
if [ -d "$NODE_PATH/Node-4/data/geth" ]; then
    rm -rf "$NODE_PATH/Node-4/data/geth"
    echo "The geth file in Node-4 has been deleted."
fi

cd $NODE_PATH/Node-0
geth --datadir data init data/genesis.json
echo "Node-0 has been initialized"

cd $NODE_PATH/Node-1
geth --datadir data init data/genesis.json
echo "Node-1 has been initialized"

cd $NODE_PATH/Node-2
geth --datadir data init data/genesis.json
echo "Node-2 has been initialized"

cd $NODE_PATH/Node-3
geth --datadir data init data/genesis.json
echo "Node-3 has been initialized"

cd $NODE_PATH/Node-4
geth --datadir data init data/genesis.json
echo "Node-4 has been initialized"
