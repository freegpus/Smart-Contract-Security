# ERC 20 Security 

Implementation must define 6 specific functions:

```solidity
// Grabbed from: https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
   function totalSupply() constant returns (uint theTotalSupply);
   function balanceOf(address _owner) constant returns (uint balance);
   function transfer(address _to, uint _value) returns (bool success);
   function transferFrom(address _from, address _to, uint _value) returns (bool success);
   function approve(address _spender, uint _value) returns (bool success);
   function allowance(address _owner, address _spender) constant returns (uint remaining);
   event Transfer(address indexed _from, address indexed _to, uint _value);
   event Approval(address indexed _owner, address indexed _spender, uint _value);
}
```

**For transferring:**

1. Do basic validation
2. Emit the transfer event upon successful transfer
3. Return a boolean true value on success

The transfer method is for a 2 party transfer, where a sender wishes to transfer some tokens to a receiver.

- Sender ➜ `transfer(receiver, amount)`

The approve + transferFrom is for a 3 party transfer, usually, but not necessarily that of an exchange, where the sender wishes to authorise a second party to transfer some tokens on their behalf.

- Sender ➜ `approve(exchange, amount)`
- Buyer ➜ executes trade on the Exchange
- Exchange ➜ `transferFrom(sender, buyer, amount)`

**Handling Failed Transfer:**

Use require(), revert(), or assert(). They all revert, no state variables are changed, gas refunded.

https://docs.openzeppelin.com/contracts/2.x/api/token/erc20#SafeERC20

**Missing Value Bug:**

Transfer and TransferFrom return booleans and must be coded for. USDT and BNB are not ERC20 compliant because of this. Over 130 cryptos weren't compliant and caused issues on Uniswap because you could add liquidity but not withdraw. 



### Securely coding an ERC20 Token

1. Handle the transfer failure either through a revert or an explicit false return. Ex: Dai is revert, 0x is false.

2. Wrap a transfer function in a "_safeTransfer" function to avoid the missing value bug. Uniswap has a good example:

```solidity
    function _safeTransfer(address token, address to, uint value) private {
    //selector = "transfer(address, uint256)". Either reverts, or returns false, and doesn't pass the require
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'UniswapV2: TRANSFER_FAILED');
    }
```

Compound Finance also has a good example using assembly/opcode:



3. Emit events on success

