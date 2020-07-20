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
    m.addBurnExempt(0x6e347f4D50f0E2F9AD86179e81097eB573920357);
    m.addBurnExempt(0xE7D6989D02dB48c4ffC663b0F770125088C2E6e5);
    m.addBurnExempt(0xB976bdA4F44Fb9d985b9c5C8c4c5362837dE6949);
    m.addBurnExempt(0xDf824317AA0B1CE4c9892b2a70F351b92d5A7236);
    m.addBurnExempt(0x6758744932533CF81523B26ef9074121102116D8);
    m.addBurnExempt(0xd4dEFDb0F2793a2eb84449a22Bf755eF622C1160);
    m.addBurnExempt(0xA1957D7413256464c8a403F2122E8F2b38F6d960);
    m.addBurnExempt(0x7C54B3eb8399f4adff273027f3aBdD200fF82F99);
    m.addBurnExempt(0x5Beaa2C98C42422C37A3B84D2C49c693351A2042);
    m.addBurnExempt(0xEf418EB1Ce666d27cCDd439ef99c62c56CE04971);
    m.addBurnExempt(0xf8E1698cDE2A80B1338d076B1cCEb6Af867Fe5f9);
    m.transfer(address(u),10000000 ether);
    m.transfer(address(s),5000000 ether);
    m.transfer(msg.sender,m.balanceOf(address(this)));
    m.transferOwnership(msg.sender);
  }
}
