// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "./SmartNFT.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract Auction {
  using Address for address payable;
  SmartNFT private _nft;
  uint private _increasePercentage;
  mapping(address => mapping(uint => uint)) private _inSale;
  mapping(address => mapping(uint => address)) private _bider;
  mapping(address => mapping(uint =>  uint)) private _bidValue;
  mapping(address => uint) private _balances;

  constructor(address nft_, uint increasePercentage_) {
    require(increasePercentage_ != 0);
    _nft = SmartNFT(nft_);
    _increasePercentage = increasePercentage_;
  }

  function nftAddress() public view returns (address) {
    return address(_nft);
  }
  function increasePercentage() public view returns (uint) {
    return _increasePercentage;
  }
  function inSale(uint id) public view returns (bool) {
    return _inSale[_nft.ownerOf(id)][id] > block.timestamp;
  }
  function lastBider(uint id) public view returns (address) {
    return _bider[_nft.ownerOf(id)][id];
  }
  function lastValue(uint id) public view returns (uint) {
    return _bidValue[_nft.ownerOf(id)][id];
  }
  function balance() public view returns (uint) {
    return _balances[msg.sender];
  }

  function setSale(uint id, uint time) public payable returns (bool) {
    require(msg.sender == _nft.ownerOf(id), "Auction: sender is not nft owner");
    require(!inSale(id), "Auction: nft already in sale");
    require(lastBider(id) == address(0) && lastValue(id) == 0, "Auction: nft already already sold");
    _nft.approve(address(this), id);
    _inSale[msg.sender][id] = block.timestamp + time;
    _bider[msg.sender][id] = msg.sender;
    _bidValue[msg.sender][id] = msg.value;
    return true;
  }
  function bid(uint id) public payable returns (bool) {
    require(inSale(id), "Auction: nft not in sale currently");
    require(msg.sender != _nft.ownerOf(id), "Auction: owner of an nft cannot bid on it");
    address _lastBider = lastBider(id);
    require(msg.sender != _lastBider, "Auction: sender already biggest bider for this nft");
    uint _lastValue = lastValue(id);
    uint amount = msg.value;
    require(amount >= _lastValue * _increasePercentage, "Auction: value too low");
    _bider[_nft.ownerOf(id)][id] = msg.sender;
    _bidValue[_nft.ownerOf(id)][id] = amount;
    _balances[_lastBider] += _lastValue;
    return true;
  }

  function getPrice(uint id) public returns (bool) {
    require(!inSale(id), "Auction: auction not ended on this nft");
    address nftOwner = _nft.ownerOf(id);
    require(msg.sender == _bider[nftOwner][id], "Auction: not winner of this auction");
    uint amount = _bidValue[nftOwner][id];
    _bider[nftOwner][id] = address(0);
    _bidValue[nftOwner][id] = 0;
    _balances[nftOwner] += amount;
    _nft.transferFrom(nftOwner, msg.sender, id);
    return true;
  }

  function withdrawBalance() public returns (bool) {
    uint amount = _balances[msg.sender];
    require(amount > 0, "Auction: sender balance empty");
    _balances[msg.sender] = 0;
    payable(msg.sender).sendValue(amount);
    return true;
  }

  function cancelSale(uint id) public returns (bool) {
    address nftOwner = _nft.ownerOf(id);
    require(msg.sender == nftOwner, "Auction: sender is not nft owner");
    require(msg.sender == lastBider(id), "Auction: cannot cancel if a bid occured");
    uint amount = _bidValue[nftOwner][id];
    _bider[nftOwner][id] = address(0);
    _bidValue[nftOwner][id] = 0;
    _balances[nftOwner] += amount;
    return true;
  }
}