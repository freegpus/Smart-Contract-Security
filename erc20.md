# ERC 20 Tokens

Must be implemented with these functions and criteria here: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md

<u>Delegate Transfer</u>

```javascript
#check on console
(await contract.allowance("your addreess", "your address")).toString()

#approve yourself
await contract.approve("your address", "number of tokens in integer format")

#move tokens
await contract.transferFrom(player, "destination account address", "number of tokens")
```

