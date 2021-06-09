// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract SmartNFT is ERC721 {
constructor(uint id) ERC721("Smart NFT", "SNFT") {
_mint(msg.sender, id);
}
}