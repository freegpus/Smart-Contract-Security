# Fallback Function Vulnerabilities

Fallback functions are just functions with no name but are external and payable like so:

```solidity
function() external payable{}
```

**FIX:** always use the `receive()` function instead of nothing

<u>Calling Fallback function:</u>

```javascript
contract.sendTransaction({value: 1})
```

