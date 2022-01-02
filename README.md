#  :milky_way:Smart Contract Security :city_sunset:

Purpose of this repo is to serve as a center of coding mistakes, bugs, and fixes for smart contract code. Included will be methods and techniques on how to exploit and secure contract code. Please use responsibly :gun:.



### :rice_scene: Front End Interaction :jack_o_lantern:

**[Web3 & Developer Console Commands](./console.md)**



### :ghost: Smart Contract Interaction :mushroom:

**<u>[Fallback Function](./fallback.md)</u>**

**<u>[Constructor Function](./constructor.md)</u>**

**<u>[Block/Blockhash](./block.md)</u>**

**<u>[Integer Under/Overflows (missing SafeMath)](./integer.md)</u>**

<u>**[Delegate Call](./delegate.md)**</u>

**<u>[Storage and Access](./storage.md)</u>**

**<u>[ERC20 Tokens](./erc20.md)</u>**



### :whale: Create Attacking Smart Contracts using Remix IDE :tiger2:

**<u>[Mimic Algorithm](./mimic.md)</u>**

<u>[**Tx.Origin**](./origin.md)</u>

[<u>**Self Destruct (forcing a contract to accept tokens)**</u>](./selfdestruct.md)

**<u>[Malicious Fallback](./king.md)</u>**

**<u>[Re-EntrancyDAO Hack/Mutex Locks](./reentrancy.md)</u>**

**<u>[Calling functions in Constructor](./constructor.md)</u>**

**<u>[Transactions/Sending Money](./transactions.md)</u>**



###  :money_with_wings:Quick Reference :moneybag:

**[Cheatsheet](https://docs.soliditylang.org/en/v0.8.10/cheatsheet.html)**

<u>Function Visibility Specifiers</u>

```
function myFunction() <visibility specifier> returns (bool) {
    return true;
}
```

- `public`: visible externally and internally (creates a [getter function](https://docs.soliditylang.org/en/v0.8.10/contracts.html#getter-functions) for storage/state variables)
- `private`: only visible in the current contract
- `external`: only visible externally (only for functions) - i.e. can only be message-called (via `this.func`)
- `internal`: only visible internally



<u>Modifiers</u>

Data on EVM = state

- `pure` for functions: Disallows modification or access of state. Good for math. Not reading any state.
- `view` for functions: Disallows modification of state. Use with interfaces to prevent modification.
- `payable` for functions: Allows them to receive Ether together with a call.
- `constant` for state variables: Disallows assignment (except initialisation), does not occupy storage slot.
- `immutable` for state variables: Allows exactly one assignment at construction time and is constant afterwards. Is stored in code.
- `anonymous` for events: Does not store event signature as topic.
- `indexed` for event parameters: Stores the parameter as topic.
- `virtual` for functions and modifiers: Allows the function’s or modifier’s behaviour to be changed in derived contracts.
- `override`: States that this function, modifier or public state variable changes the behaviour of a function or modifier in a base contract.
