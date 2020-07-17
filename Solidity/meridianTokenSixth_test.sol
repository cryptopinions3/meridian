pragma solidity >=0.4.22 <0.7.0;
import "./IERC20.sol";
import "./SafeMath.sol";
import "./Interfaces.sol";
import "./Actor.sol";
import "./deploy.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite {
    DeployMeridian d;
    Actor a1;
    Actor a2;
    uint startTime=now;

    event Print(uint val,string str);
    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        // Here should instantiate tested contract
        Assert.equal(uint(1), uint(1), "1 should be equal to 1");
        d=new DeployMeridian();
        IERC(d.m())._mint(address(this),1000000 ether);
        IERC(d.m()).addBurnExempt(address(this));
        IStake(d.s()).activateContract();
        IERC(d.m()).transfer(address(d.s()),1000 ether);
        a1=new Actor(IERC(d.m()),IStake(d.s()));
        a2=new Actor(IERC(d.m()),IStake(d.s()));
    }
    function testTimeWithdraw() public{
      a1.stake(1000 ether);
      a1.withdrawDivs();
      Assert.equal(uint(0),IStake(d.s()).getDividends(address(a1)),"a1 should not have divs here");
      Assert.equal(uint(0),IStake(d.s()).getDividends(address(a2)),"a2 should not have divs here");
      //emit Print(IStake(d.s()).getDividends(address(a1)),"dividends after 0 hours a1");
      IStake(d.s()).setNowTest(startTime+12 hours);
      emit Print(IStake(d.s()).getDividends(address(a1)),"dividends after 12 hours a1");
      //1k finney = 1 eth, looking for 5 (starts 1k, half of 1%)
      Assert.greaterThan(uint(5010 finney),IStake(d.s()).getDividends(address(a1)),"a1 should get time divs");
      Assert.greaterThan(IStake(d.s()).getDividends(address(a1)),uint(4990 finney),"a1 should get time divs");
      a1.stake(1000); //update checkpoint and change staked balance, this should not affect divs
      Assert.greaterThan(uint(5010 finney),IStake(d.s()).getDividends(address(a1)),"a1 should get time divs");
      Assert.greaterThan(IStake(d.s()).getDividends(address(a1)),uint(4990 finney),"a1 should get time divs");
      a1.unstake(1000); //unstake should return unstaked amount minus fee, also should not affect divs

      Assert.greaterThan(uint(5010 finney),IStake(d.s()).getDividends(address(a1)),"a1 should get time divs");
      Assert.greaterThan(IStake(d.s()).getDividends(address(a1)),uint(4990 finney),"a1 should get time divs");
      Assert.equal(1000 ether,IStake(d.s()).amountStaked(address(a1)),"a1 should have 1k staked at this stage");
    }



}
