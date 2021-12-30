

# Malicious Fallback Function

Never ever assume that an address/contract has a properly coded fallback function.

Vuln code example:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract King {

  address payable king;
  uint public prize;
  address payable public owner;

  constructor() public payable {
    owner = msg.sender;  
    king = msg.sender;
    prize = msg.value;
  }

  receive() external payable {
    require(msg.value >= prize || msg.sender == owner);
    king.transfer(msg.value);
    king = msg.sender;
    prize = msg.value;
  }

  function _king() public view returns (address payable) {
    return king;
  }
}
```



The `king.transfer()`assumes that the receiving contract has a properly coded fallback function. But we can break it by just saying revert in there like so:



![king](/home/workstation1/Documents/repos/smartcontracts/screenshots/king.png)