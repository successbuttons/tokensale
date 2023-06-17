// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IToken {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract TestController {
    event TokenPurchased(address indexed _owner, uint256 _amount, uint256 _bnb);

    IToken token;

    bool public isPreselling;
    address payable owner;
    address payable tokenSource = payable(0x8238eD4aF596F44B34310D3FD66a4AE12d88561b);
    address payable fundReceiver;

    uint256 soldTokens;
    uint256 receivedFunds;

    constructor(IToken _tokenAddress) {
        token = _tokenAddress;
        owner = payable(msg.sender);
        fundReceiver = owner;
        isPreselling = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    function sale(uint256 _amount) public payable returns (bool) {
        require(isPreselling, "Pre-selling is over.");

        bool transferSuccess = token.transferFrom(tokenSource, msg.sender, _amount);
        require(transferSuccess, "Token transfer failed");

        bool sendSuccess = fundReceiver.send(msg.value);
        require(sendSuccess, "Failed to send funds");

        soldTokens += _amount;
        receivedFunds += msg.value;
        emit TokenPurchased(msg.sender, _amount, msg.value);
        return true;
    }

    function getTokenSupply() public view returns (uint256) {
        return token.totalSupply();
    }

    function getTokenBalance(address _address) public view returns (uint256) {
        return token.balanceOf(_address);
    }

    function totalSoldTokens() public view returns (uint256) {
        return soldTokens;
    }

    function totalReceivedFunds() public view returns (uint256) {
        return receivedFunds;
    }

    function getBalance() public onlyOwner {
        owner.transfer(address(this).balance);
    }

    function setReceiver(address payable _fund) public onlyOwner {
        fundReceiver = _fund;
    }

    function setPreSellingStatus() public onlyOwner {
        isPreselling = !isPreselling;
    }
}
