# Constructor

Always use the `constructor()` function. It should never be callable.

Only gets executed once in lifecycle of contract. Can also have the exact name of the contract.

If you see the constructor function in the ABI of the contract, it's game over...

```javascript
contract.abi
#if you see constructor in here, that's a big error
```



### Calling functions inside of constructor

```solidity
pragma solidity ^0.6.0;

contract gatekeeperAttack{

	constructor(address _addr) public {
		bytes8 _key = //a ^ b = c == a ^ c = b
		
		//assuming function is function enter(bytes8 _gateKey) public returns (bool)
		_addr.call(abi.encodeWithSignature('enter(bytes8)', _key)); 
	}
} 
```

