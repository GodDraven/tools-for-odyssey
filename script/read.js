// const contractAbi = "[{"inputs":[{"internalType":"uint256","name":"initVal","type":"uint256"}],"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"_to","type":"address"},{"indexed":false,"internalType":"uint256","name":"_amount","type":"uint256"}],"name":"stored","type":"event"},{"inputs":[],"name":"get","outputs":[{"internalType":"uint256","name":"retVal","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"x","type":"uint256"}],"name":"set","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"storedData","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}]";
var {Web3} = require("web3");
const contractAbi =  [
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "initVal",
          "type": "uint256"
        }
      ],
      "stateMutability": "nonpayable",
      "type": "constructor"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "address",
          "name": "_to",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "_amount",
          "type": "uint256"
        }
      ],
      "name": "stored",
      "type": "event"
    },
    {
      "inputs": [],
      "name": "get",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "retVal",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "x",
          "type": "uint256"
        }
      ],
      "name": "set",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "storedData",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    }
  ]

const contractAddress = "0x049f115eE4d1DF639caC28C50Bf07247D50B1867";

async function getValueAtAddress(
    host,
    deployedContractAbi,
    deployedContractAddress,
  ) {
    const web3 = new Web3(host);
    const contractInstance = new web3.eth.Contract(
      deployedContractAbi,
      deployedContractAddress,
    );
    const res = await contractInstance.methods.get().call();
    console.log("Obtained value at deployed contract is: " + res);
    return res;
  }

async function main() {
    // console.log("This is a log message");
    getValueAtAddress(
        "http://localhost:22001",
        contractAbi,
        contractAddress,
    )
}

if (require.main === module) {
    main();
}

module.exports = exports = main
