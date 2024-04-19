const path = require("path");
const fs = require("fs-extra");
var {Web3} = require("web3");
// use the existing Member1 account address or make a new account
const address = "0xce3a70d3d207ea92c54b4d6e59d07b8e6d4caf96";

// read in the contracts
const contractJsonPath = path.resolve(__dirname, "SimpleStorage.json");
const contractJson = JSON.parse(fs.readFileSync(contractJsonPath));
const contractAbi = contractJson.abi;
const contractByteCode = contractJson.evm.bytecode.object;

async function createContract(
    host,
    contractAbi,
    contractByteCode,
    contractInit,
    fromAddress,
) {
    const web3 = new Web3(new Web3.providers.HttpProvider(host));
    const contractInstance = new web3.eth.Contract(contractAbi);
    const ci = await contractInstance
        .deploy({ data: "0x" + contractByteCode, arguments: [contractInit] })
        .send({ from: fromAddress, gasLimit: "0x300000" })
        .on("transactionHash", function (hash) {
            console.log("The transaction hash is: " + hash);
        });
    return ci;
}

// create the contract
async function main() {
    // using Member1 to send the transaction from
    createContract(
        "http://localhost:22001",
        contractAbi,
        contractByteCode,
        47,
        address,
    )
        .then(async function (ci) {
            console.log("Address of transaction: ", ci.options.address);
        })
        .catch(console.error);
}

if (require.main === module) {
    main();
}

module.exports = exports = main