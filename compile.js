/** COMPILATION */
const solc = require('solc');   // solidity compiler
const fs = require('fs-extra');       // file system will be used for wreading sc and writing compiled code to a file
const path = require('path');

// name of smart contract file
const contractFile = 'MyICO.sol';
// path to the smart contrcat file
const contractPath = path.resolve(__dirname, 'contract', contractFile);
// path to the build folder
const buildPath = path.resolve(__dirname, 'build');

// delete entire build folder if it exists
fs.removeSync(buildPath);

// making sure build folder is present in project directory
fs.ensureDirSync(buildPath);
// reading smart contract cide
const contractSource = fs.readFileSync(contractPath, 'utf-8');

// input to the solidity compiler
const input = {
    language: 'Solidity',
    sources: {
        contractFile : {
            content: contractSource
        }
    },
    settings: {
        outputSelection: {
           '*': {
                '*': [ '*' ]
            }
        }
    }
};

// compiling Smart contract
const compiledContract = JSON.parse(solc.compile(JSON.stringify(input)));
fs.outputJSONSync(
    path.resolve(__dirname, `compiledContract.json`),
    compiledContract
);

// extracting required compiled data
const contractMyICO = compiledContract['contracts']['contractFile'];

// saving required compiled data to build folder
for (let contract in contractMyICO) {
    fs.outputJSONSync(
        path.resolve(buildPath, `${contract}.json`),
        contractMyICO[contract]
    );
}

// /** DEPLOYMENT */
// read compiled file and extract abi and bytecode
const compiledFilePath = path.resolve(__dirname, 'build', 'MyICO.json');
const compiledData = JSON.parse(fs.readFileSync(compiledFilePath, 'utf8'));
const abi = compiledData['abi']
const bytecode = compiledData['evm']['bytecode']['object']

// start web3 instance
const Web3 = require('web3');
const web3 = new Web3(new Web3.providers.HttpProvider('HTTP://127.0.0.1:7545'));

// creating contract instance using abi
const contract = new web3.eth.Contract(abi);

// deploy contract
let deploy = async () => {
    const accounts = await web3.eth.getAccounts();

    const deployedContract = await contract.deploy({
        arguments: ["sid", "sid", 10000, 1000, 100, 100, 300],
        data:bytecode
    }).send({ from: accounts[0], gas: 10000000 });
    console.log("Contract Deployed");
    const contractAddress = await deployedContract.contractAddress();
    console.log(contractAddress);
    const unsoldTokens = await deployedContract.getUnsoldTokenCount().call({ from: accounts[0] });
    console.log(`Unsold Tokens: ${unsoldTokens}`);
}
deploy();