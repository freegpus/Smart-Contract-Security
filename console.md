# Developer Console Commands & Code

<u>Checking Contract:</u>

```javascript
#Check ABI
contract

#check address
contract.address

#check owner, update Chrome if await is not working
await contract.owner()

#check balance
await getBalance(contract.address)
(await contract.balanceOf("addresshere")).toString()
```

<u>Calling functions in contract:</u>

```javascript
#to read data for free for a function that returns something
await contract.functionName()

#to input a value, check what the msg.variable name is. For instance if it's require(msg.value < 0.001 ether); use the named function in the contract, in this case it's contribute()

#notice there's no await in front of it
contract.contribute({value:1})
```

### Web3 JS functions

```javascript
#Calling Fallback function, send transaction always goes to the payable function
contract.sendTransaction({value: 1})
```

```javascript
#create function signature
var pwnFuncSignature = web3.utils.sha3("pwn()")

#pass in the function sig
contract.sendTransaction({data: pwnFuncSignature})

#declare a variable
var pass

#query storage (can read private variables) at specific index
web3.eth.getStorageAt(contract.address, 1, function(err, result){pass = result})

#convert hex to ascii
web3.utils.toAscii(pass)

#Query all storage
let storage = []

let callbackFNConstructor = (index) => (error, contractData) => {
    storage[index] = contractData
}

for(var i=0; i < 6; i++){
    web3.eth.getStorageAt(contract.address, i, callbackFNConstructor(i))
}

#check the new storage variable
storage
```

```javascript
#getting contract address made from address
web3.utils.soliditySha3("0xd6", "0x94", "address of owning contract", "0x01")
#resulting contract, take the last 40 characters
```



### Encoding functions from console (necessary if contract that has the code is not the current instance we are working with)

```javascript
#passes player address to _to var

data = web3.eth.abi.encodeFunctionCall({
	name: 'destroy',
	type: 'function',
	inputs: [{
		type:'address',
		name:'_to'
	}]
}, [player/"address"]);

#sending transaction using previous encoding
await web3.eth.sendTransaction({
    to: "target contract address with the prev function in it",
    from: player,
    data: data
})
```

