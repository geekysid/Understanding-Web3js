// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// sid,sid,10000,1000,100,100,300

contract MyICO {

    uint unsoldTokens = 0;
    uint immutable tokenSupply;
    uint immutable ethToToken;
    uint immutable tokensForSale;
    uint immutable minPurchaseLimit;
    uint immutable maxPurchaseLimit;
    string public tokenName;
    string public tokenSymbol;
    address payable wallet;
    mapping(address => uint) balances;
    mapping(address => bool) whitelist;

    constructor (string memory _tokenName, string memory _tokenSymbol, uint _tokenSupply, uint _tokensForSale, uint _tokenPrice, uint _minPurchaseLimit, uint _maxPurchaseLimit) {
        wallet = payable(msg.sender);
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;
        tokenSupply = _tokenSupply;
        tokensForSale = _tokensForSale;
        unsoldTokens = _tokensForSale;
        ethToToken = _tokenPrice;
        minPurchaseLimit = _minPurchaseLimit;
        maxPurchaseLimit = _maxPurchaseLimit;
    }

    event Purchased(address, uint);

    modifier isOwner {
        require(msg.sender == wallet, "Only owner can access this");
        _;
    }

    modifier isWhitelisted {
        require(whitelist[msg.sender], "This address is not whitelisted.");
        _;
    }

    modifier isSaleOpen {
        require(unsoldTokens > 0, "Token Sale is over as all tokens are sold");
        _;
    }

    // whitelisting an address
    function whitelistUser(address _adr) external isOwner {
        require(!whitelist[_adr], "Address is already whitelisted!!");
        whitelist[_adr] = true;
    }

    // check if account is whitelisted
    function checkWhitelistedAccount() external view returns (bool) {
        return whitelist[msg.sender];
    }

    // buy tokens similar to ICO
    function buyToken() external payable isWhitelisted isSaleOpen {
        uint tokensPurchased = (msg.value/1 ether) * ethToToken;
        require(tokensPurchased >= minPurchaseLimit, string(bytes.concat(bytes("You have breached"), bytes(" Min Token Purchase limit"))));
        require(tokensPurchased <= maxPurchaseLimit, string(bytes.concat("You have breached", " Max Token Purchase limit")));
        require(unsoldTokens >= tokensPurchased, "Not enough token to purchase");
        balances[msg.sender] += tokensPurchased;
        unsoldTokens -= tokensPurchased;

        // send ether to address where transaction was initiated
        wallet.transfer(msg.value);
        emit Purchased(msg.sender, tokensPurchased);
    }

    // get count of tokens purchased
    function getTokenPurchasedCount() external view returns (uint) {
        return balances[tx.origin];
    }

    // get count of total unsolde tokens
    function getUnsoldTokenCount() external view returns (uint) {
        return unsoldTokens;
    }

    // get count of total unsolde tokens
    function totalEthContributed() external view returns (uint) {
        return address(this).balance;
    }
}
