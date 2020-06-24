pragma solidity ^0.4.26;

import "./IERC20.sol";
import "./SafeMath.sol";

contract MeridianStaking{
  using SafeMath for uint;
  ERC20 public meridianToken;
  constructor(address token) public{
    meridianToken=ERC20(token);
  }

  function stake(uint amount) public{
    meridianToken.transferFrom(msg.sender,address(this),amount);

  }
  function unstake(uint amount) public{

  }
  function withdrawDivs() public{

  }
  function reinvestDivs() public{
  
  }
}
