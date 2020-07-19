pragma solidity 0.4.26;


// Meridian Network token

import "./IERC20.sol";
import "./SafeMath.sol";
import "./meridianToken.sol";
import "./staking.sol";
import "./upgrade.sol";

contract DeployMeridian{
  Meridian public m;
  MeridianStaking public s;
  MeridianUpgrade public u;
  address public previousToken= 0x896a07e3788983ec52eaf0F9C6F6E031464Ee2CC;

  constructor() public{
    m = new Meridian();
    s = new MeridianStaking(address(m));
    u = new MeridianUpgrade(previousToken,address(m));
    m.addBurnExempt(address(s));
    m.addBurnExempt(address(u));
    m.addBurnExempt(msg.sender);
    m.addBurnExempt(address(m));
    m.addBurnExempt(address(this));
    m.transfer(address(u),10000000 ether);
    m.transfer(address(s),5000000 ether);
    m.transfer(msg.sender,m.balanceOf(address(this)));
    m.transferOwnership(msg.sender);
  }
}
