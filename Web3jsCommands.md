## Console
----------------------------------------------------------------

- Start Ganache

- Got to Remix and follow below steps -
    - Select **Web3 Probider** as environment of deployment.

    - Deploy the contact (the contract I 'm using for this can be found here).

    - Copy the deployed **contract address** from the same section and save it somehwere as we will be needing it later.

    - Again, go to the Compilation section, and copy and save the **ABI** to some place as we will be needing it also.

- Just to simply describe the Smart Contract that I am using, this is a ICO smart contract (a very vague one) and have below mentioned functions -
    - *whitelistUser*: function called by owner of smart contract to whitelist users for ICO.

    - *buyToken*: function that allows only whitelisted accounts to buy token.

    - *getTokenPurchasedCount*: function to let whitelisted user know how many tokens has he purchansed so far.

    - *getUnsoldTokenCount*: function to know how many tokens are still available to in ICO that whitelisted users can buy.

    - *totalEthContributed*: function that returns total number of eths send to contract in ICO

    - *checkWhitelistedAccount*: function that can be used by user to know if they are whitelisted.

- No head over to terminal where we will be using web3js to interact with the smart contract deployed on Ganache in previous steps.

    - Import web3 library. Here we basically get a class returned.

        `const Web3 = require("web3";`

    - Instantiate web3 object using Ganache's RPC server. This will connect us to the blockchain running on Ganache and also give us control of all accounts that are available in Ganache.

        `const web3 = new Web3(new Web3.providers.HttpProvider("HTTP://127.0.0.1:7545"));`

    - Get all accounts and save it to a variable so that it will be easily accessible throughout the project.

        `const accounts = await web3.eth.getAccounts();`    // returns a list of all available accounts

    - Let's whitelist account[1] using accounts[0] (owner of the contract).

        `await web3.methods.whitelistUser(account[1]).send({ from: accounts[0] });

    - Now use accounts[1] to check if it is whitelisted.

        `await web3.methods.checkWhitelistedAccount().call({ from: accounts[0] });`

    - Now we will use this whitelisted account to buy tokens worth 1 ether.

        `await web3.methods.buyToken().send({ from accounts[1], value: web3.utils.toWei("1", "ether) })`;

    - Now we will check if tokens are added to accounts[1]

        `await web3.methods.getTokenPurchasedCount().send({ from: accounts[1] })`

    - Again lets check balance of accounts[1] awhich should be reduced by 1 eth.

        `await web3.eth.getBalance(accounts[1]);`    // returns a list of all available accounts

    - Now lets check how many eth are avaible in contract.

        `await web3.methods.totalEthContributed().call({ from: accounts[0] });`    // returns a list of all available accounts

    - Similary we can check total tokens still available to buy as below:

        `await web3.methods.getUnsoldTokenCount().call({ from: accounts[1] });`

<br>

## Compiling and Deploying Smart contract isng JS
----

Even though truffle has made it very easy to compile and deploy any smart contract on blockchain, its always a good practice to know how we can do it from scratch.

### Compile Smart Contracts

In order to get connected to the smart contract, web3 needs to have access to the ABI of the smart contract. So far we have basically copied the API from remix editor but this is not going to be ideal situation and so we need to have a process we can compile the Smart Contract using javascript and get an ABI.

- We need below libraries

  `const solc = require('solc');    // solidity compiler`

  `cosnt fs = require('fs-extra'); // file system that will be used to read the read the smart contract file`

  `cosnt path = require('path');  // used to reach out to the build folder as we will save our ABI and bytecode in build folder`

- Read the contect of smart contract and save it to a file.

  `const contractFile = "MyICO.sol"`

  `const contractPath = path.resolve(__dirname, 'contract', contractFile); // generating path of cotract file`

  `const source = fs.readFileSync(fileName, 'utf8');  // reading smart contract content and saving to a file`

- Default input to the json file looks like below:

        // input to the solidity compiller
        const input = {
            language: 'Solidity',
            sources: {
                contractFile : {
                    content: source
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


- Compiling our contract

  `const compiledContract = JSON.parse(solc.compile(JSON.stringify(input));`

  `const contractOutput = compiledContract['contracts'][contractFile];`

- Creating a *build* folder and saving our compile contract in the same.

  `const buildPath = path.resolve(__dirname, 'build');  // path to build folder`

  `fs.ensureDirSync(buildFolder);`

- Save the comiled contract to a fil ein build folder

        for (let contract in contractOutput) {
            fs.outputJSONSync(
                path.resolve(buildPath, `${contract}.json`),
                contractOutput[contract]
            );
        }


### Deploy Smart Contracts

Now that we have compiled our smart contract and have our ABI and Bytecode in the file

- Extract abi and bytecode from saved compiled contract file

  `const compiledFilePath = path.resolve(__dirname, 'build', MyICO.json);`

  `const compiledData = JSON.parse(fs.readFileSync(compiledFilePath);`

  `const abi = compiledData['abi'];`

  `const bytecode = compiledData['evm']['bytecode']['object'];`

- Create web3 instance

  `const Web3 = require('web3);`

  `const web3 = new Web3(new Web3.providers.HttpProvider('GANACHE RPC));`

- Create contract instance using ABI

  `const contract = web3.eth.Contract(abi);`

- Deploy Contract

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



