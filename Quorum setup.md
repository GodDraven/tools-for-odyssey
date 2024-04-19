# Quorum Tutorial

This document introduce how to setup and use Go-Quorum framework.



## 1. Setup Quorum

This part introduce how to setup Go-Quorum framework, you can choose to setup with its Quickstart tools or build from source for development.

make sure the guest has big enough disk and memory.



## 1.1 Use Quorum Developer Quickstart

### Prerequisites

* update and upgrade apt-get and apt

```bash
sudo apt-get update && sudo apt-get upgrade
sudo apt update && sudo apt upgrade
```

* `npm` and `node.js` with version 14 or higher.

```bash
# install npm and nvm.
sudo apt-get update npm
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
```

```bash
# use nvm to install nodejs 16
nvm install 16.0.0
nvm use 16.0.0
```

```bash
# check nodejs' version
node -v
```

* docker and docker-compose

follow the reference [here](https://computingforgeeks.com/install-docker-desktop-on-ubuntu/).

* hardhat and curl

```bash
npm install --save-dev hardhat
```

```bash
sudo apt-get install curl
```

### Use the Quickstart tools

1. Generate the tutorial blockchain configuration files

```bash
npx quorum-dev-quickstart
```

2. Start the network

before start network, start docker compose and deamon service, and set docker's memory to 4GB or 6GB (modify the `setting.json` then restart docker service or reboot) if  private transaction is on.

```
./run.sh
```



## 1.2 Build from source

1. use Go version 1.15 or later (1.21.1 test ok), and solc should lower then 0.8.20.

direction of installing go: follow the reference [here](https://go.dev/doc/install).

2. Clone the repository and build the source:

```bash
git clone https://github.com/Consensys/quorum.git
```

```bash
cd quorum
```

```bash
make all
```

if compile no reaction, modify the proxy

```bash
go env -w GOPROXY=https://goproxy.cn
```

3. try test

```bash
make test
```

4. add Quorum to `PATH`

```bash
vim ~/.bashrc
```

```bash
# add this to ".bashrc"
export PATH=$PATH:/path/to/repository/build/bin
```

```bash
source ~/.bashrc
```



## 2. Create private network 

Official docs for creating private network with QBFT [here](https://docs.goquorum.consensys.net/tutorials/private-network/create-qbft-network) is quite elaborate, follow the steps.

To create a private network with IBFT [here](https://docs.goquorum.consensys.io/tutorials/private-network/create-ibft-network), follow the steps except section 4: Copy the static nodes file and node keys to each node. Please refer to the corresponding section in QBFT.

To start nodes more conveniently, use the [`start_node.sh`](https://github.com/jianyu-niu/Vechain-Project/blob/main/script/start_node.sh) and [`stop_node.sh`](https://github.com/jianyu-niu/Vechain-Project/blob/main/script/stop_node.sh) (put them in project root).

## 3. Deploy a smart contract and transaction

1. create directory `contract` and create [`compile.js`](https://github.com/jianyu-niu/Vechain-Project/blob/main/script/compile.js) and [`SimpleStorage.sol`](https://github.com/jianyu-niu/Vechain-Project/blob/main/contract/SimpleStorage.sol) with content in the links.

2. compile contract:

```bash
node compile.js
```

then the project structure will be like:

```
Project_Root/
 └── contract
      ├── compile.js
      ├── SimpleStorage.json
      └── SimpleStorage.sol
```

run ```solc``` to get the contract's binary and abi:

```
solc SimpleStorage.sol --bin --abi
```
The output will be like:
```
Binary:
608060405234801561001057600080fd5b5060405161038a38038061038a833981810160405281019061003291906100b3565b7fc9db20adedc6cf2b5d25252b101ab03e124902a73fcb12b753f3d1aaa2d8f9f53382604051610063929190610130565b60405180910390a18060008190555050610159565b600080fd5b6000819050919050565b6100908161007d565b811461009b57600080fd5b50565b6000815190506100ad81610087565b92915050565b6000602082840312156100c9576100c8610078565b5b60006100d78482850161009e565b91505092915050565b600073ffffffffffffffffffffffffffffffffffffffff82169050919050565b600061010b826100e0565b9050919050565b61011b81610100565b82525050565b61012a8161007d565b82525050565b60006040820190506101456000830185610112565b6101526020830184610121565b9392505050565b610222806101686000396000f3fe608060405234801561001057600080fd5b50600436106100415760003560e01c80632a1afcd91461004657806360fe47b1146100645780636d4ce63c14610080575b600080fd5b61004e61009e565b60405161005b9190610109565b60405180910390f35b61007e60048036038101906100799190610155565b6100a4565b005b6100886100e7565b6040516100959190610109565b60405180910390f35b60005481565b7fc9db20adedc6cf2b5d25252b101ab03e124902a73fcb12b753f3d1aaa2d8f9f533826040516100d59291906101c3565b60405180910390a18060008190555050565b60008054905090565b6000819050919050565b610103816100f0565b82525050565b600060208201905061011e60008301846100fa565b92915050565b600080fd5b610132816100f0565b811461013d57600080fd5b50565b60008135905061014f81610129565b92915050565b60006020828403121561016b5761016a610124565b5b600061017984828501610140565b91505092915050565b600073ffffffffffffffffffffffffffffffffffffffff82169050919050565b60006101ad82610182565b9050919050565b6101bd816101a2565b82525050565b60006040820190506101d860008301856101b4565b6101e560208301846100fa565b939250505056fea26469706673582212200c3775e8c745ccd95b0d78c93e5e910db6497347e38032988de67d876a1db8c364736f6c63430008130033
Contract JSON ABI
[{"inputs":[{"internalType":"uint256","name":"initVal","type":"uint256"}],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"_to","type":"address"},{"indexed":false,"internalType":"uint256","name":"_amount","type":"uint256"}],"name":"stored","type":"event"},{"inputs":[],"name":"get","outputs":[{"internalType":"uint256","name":"retVal","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"x","type":"uint256"}],"name":"set","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"storedData","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}]
```

3. deploy the contract: (modify port number and `from` address to node 1)

+ Using JSON-RPC to post request to the API ``eth_sendTransaction`,

only return transaction hash, need to use`eth_getTransactionReceipt` to get contract address.

The parameter "from" is the content of file ```accountAddress``` in each Node file. "data" is the binary code generated from last step. And you also need to modify the host's port binding with corresponding node.

```bash
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_sendTransaction","params":[{"from":"0xce3a70d3d207ea92c54b4d6e59d07b8e6d4caf96", "to":null, "gas":"0x24A22","gasPrice":"0x0", "data":"0x608060405234801561001057600080fd5b5060405161014d38038061014d8339818101604052602081101561003357600080fd5b8101908080519060200190929190505050806000819055505060f38061005a6000396000f3fe6080604052348015600f57600080fd5b5060043610603c5760003560e01c80632a1afcd914604157806360fe47b114605d5780636d4ce63c146088575b600080fd5b604760a4565b6040518082815260200191505060405180910390f35b608660048036036020811015607157600080fd5b810190808035906020019092919050505060aa565b005b608e60b4565b6040518082815260200191505060405180910390f35b60005481565b8060008190555050565b6000805490509056fea2646970667358221220e6966e446bd0af8e6af40eb0d8f323dd02f771ba1f11ae05c65d1624ffb3c58264736f6c63430007060033"}], "id":1}' -H 'Content-Type: application/json' http://localhost:22001
```



+ Using `web3.eth.Contract`, create [`public_tx_web3.js`](https://github.com/jianyu-niu/Vechain-Project/blob/main/script/public_tx_web3.js) and run with `node`, you'll get:

(modify the host's port and address to any Node except Node-0, address is the same as the parameter "from")

```js
The transaction hash is: 0x480319ed8923c78310185a96811e2182ef69951c9dfd87cb656b5e061b0c281c
Address of transaction:  0xcDcbf56f90645e3625229214bfc8e129480D6890
```

which means you deploy successfully, and you can use the address of transaction to call contract function.
