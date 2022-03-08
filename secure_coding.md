# Solidity Secure Coding Practices

**General best practices:**

1. Explicitly stating the permission level  of functions and data structures
2. Ownership
3. Circuit Breaker to be able to pause all contract functionality. Can be set to 0x0 later on.
4. Sanitizing data coming outside of contract.
5. Fail early and fail loud

**Good design patterns:**

1. Separate actions such as checking balance, transferring and withdrawal. 
2. Double check functions that can be called externally and if they should be.
3. State machine: require certain conditions be met at beginning of function before allowing to proceed
4. Commit/reveal: encrypt on the front end, not on the backend. Then users can reveal later. 
5. Action throttling. Making sure a certain amount of blocks pass before validating a transaction.
6. Automatic deprecation/self destruct when a condition/block is met.
7. Data segregation/upgradability

### external

Only functions can be marked external. External functions are part of the contract interface and can be called from other contracts and transactions. They can't be called internally. This leads to external functions being cheaper to execute.

## public

Both state variables (the 'properties' of your contract) and functions can be marked as public.

Public state variables and functions can both be accessed from the outside and the inside. The Solidity compiler automatically creates a getter function for them.

## internal

internal is the default visibility for state variables.

Internal functions and state variables can both be accessed from within the same contract and in deriving contracts. They aren't accessible from the outside.

## private

Private is the most restrictive visibility.

State variables and functions marked as private are only visible and accessible in the same contract.
