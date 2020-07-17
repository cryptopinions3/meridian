pragma solidity ^0.4.26;

import "./IERC20.sol";
import "./Interfaces.sol";
contract Actor{
  //IERC public oldtoken;
  IERC public token;
  IStake public staking;
  //IUpgrade public upgrade;
  constructor(IERC t,IStake s) public{
    token=t;
    staking=s;
    //upgrade=u;
    //oldtoken._mint(address(this),10000 ether);
    token._mint(address(this),10000 ether);
  }
  function stake(uint amount) public{
    //staking.stake(amount);
    token.approveAndCall(address(staking),amount,abi.encodePacked(0));
  }
  function unstake(uint amount) public{
    staking.unstake(amount);
  }
  function withdrawDivs() public{
    staking.withdrawDivs();
  }
  function reinvestDivs() public{
    staking.reinvestDivs();
  }
  function transferTokens(address a,uint amount) public{
    token.transfer(a,amount);
  }
}
