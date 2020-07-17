pragma solidity >=0.4.22 <0.7.0;
import "./IERC20.sol";
import "./SafeMath.sol";
import "./Interfaces.sol";
import "./meridianToken.sol";
import "./deploy.sol";
import "./Actor.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite {
    DeployMeridian d;
    Actor a1;
    Actor a2;
    Actor a3;
    uint startTime=now;

    event Print(uint val,string str);
    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        d=new DeployMeridian();
        IERC(d.m())._mint(address(this),1000000 ether);
        IERC(d.m()).addBurnExempt(address(this));
        IStake(d.s()).activateContract();
        IERC(d.m()).transfer(address(d.s()),1000 ether);
        a1=new Actor(IERC(d.m()),IStake(d.s()));
        a2=new Actor(IERC(d.m()),IStake(d.s()));
    }

    function testBurnWithdraw() public{
      a1.stake(1000 ether);
      a2.stake(2000 ether);
      a2.unstake(2000 ether);
      //emit Print(IStake(d.s())).getDividends(address(a2)),"a2 divs");
      //emit Print(IStake(d.s())).getDividends(address(a1)),"a1 divs");
      Assert.greaterThan(uint(10000 ether),IERC(d.m()).balanceOf(address(a2)),"a2 should not have more than what they started with");
      Assert.greaterThan(IERC(d.m()).balanceOf(address(a2)),uint(9000 ether),"a2 should get back most");
      //between 33 and 34 tokens, 1/3 of 100 tokens distributed from 2000 unstake (5%)
      Assert.greaterThan(uint(34 ether),(IStake(d.s())).getDividends(address(a1)),"a1 should get divs");
      Assert.greaterThan(IStake(d.s()).getDividends(address(a1)),uint(33 ether),"a1 should get divs");
      Assert.greaterThan(uint(67 ether),(IStake(d.s())).getDividends(address(a2)),"a2 should get divs");
      Assert.greaterThan(IStake(d.s()).getDividends(address(a2)),uint(66 ether),"a2 should get divs");
      a1.stake(1000 ether); //update checkpoint and change staked balance, this should not affect divs
      Assert.greaterThan(uint(67 ether),(IStake(d.s())).getDividends(address(a2)),"a2 should get divs");
      Assert.greaterThan(IStake(d.s()).getDividends(address(a2)),uint(66 ether),"a2 should get divs");

      uint a1bal=IERC(d.m()).balanceOf(address(a1));
      a1.withdrawDivs();
      uint a1bal2=IERC(d.m()).balanceOf(address(a1));
      uint a1baldif=a1bal2-a1bal;
      //subtract 10% burn fee
      Assert.greaterThan(uint(31 ether),a1baldif,"a1 should get divs in tokens");
      Assert.greaterThan(a1baldif,uint(29 ether),"a1 should get divs in tokens");
    }


}
