pragma solidity >=0.4.22 <0.7.0;
import "./IERC20.sol";
import "./SafeMath.sol";
import "./Interfaces.sol";
import "./meridianToken.sol";
//import "./staking.sol";
import "./Actor.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract testSuite {
    //MeridianStaking public staking;
    //IUpgrade public upgrade;
    Meridian public token;
    Actor a1;
    Actor a2;
    Actor a3;
    uint startTime=now;

    event Print(uint val,string str);
    /// 'beforeAll' runs before all other tests
    /// More special functions are: 'beforeEach', 'beforeAll', 'afterEach' & 'afterAll'
    function beforeAll() public {
        // Here should instantiate tested contract
        Assert.equal(uint(1), uint(1), "1 should be equal to 1");
        token=new Meridian();
        token._mint(address(this),1000000 ether);
        token.addBurnExempt(address(this));
        //upgrade=IUpgrade(address(token.upgradeContract));
        //staking=token.stakingContract;
        d.s().activateContract();
        //staking.burnAfterContractEnd();
        token.transfer(address(d.s()),1000 ether);
        a1=new Actor(IERC(token),IStake(d.s()));
        a2=new Actor(IERC(token),IStake(d.s()));
        a3=new Actor(IERC(token),IStake(d.s()));
    }
    function testStake() public{
      a1.stake(1000 ether);
      a2.stake(2000 ether);
      Assert.equal(5004000 ether,token.balanceOf(d.s()),"token balance should be equal");
      a2.unstake(2000 ether);
      a2.withdrawDivs();
      //emit Print(d.s().getDividends(address(a1)),"dividends before withdraw a1");
      a1.withdrawDivs();
      //emit Print(d.s().getDividends(address(a1)),"dividends after withdraw a1");
    }
    function testTimeWithdraw() public{
      Assert.equal(uint(0),d.s().getDividends(address(a1)),"a1 should not have divs here");
      Assert.equal(uint(0),d.s().getDividends(address(a2)),"a2 should not have divs here");
      //emit Print(d.s().getDividends(address(a1)),"dividends after 0 hours a1");
      d.s().setNowTest(startTime+12 hours);
      emit Print(d.s().getDividends(address(a1)),"dividends after 12 hours a1");
      //1k finney = 1 eth, looking for 5 (starts 1k, half of 1%)
      Assert.greaterThan(uint(5010 finney),(d.s()).getDividends(address(a1)),"a1 should get time divs");
      Assert.greaterThan((d.s()).getDividends(address(a1)),uint(4990 finney),"a1 should get time divs");
      a1.stake(1000); //update checkpoint and change staked balance, this should not affect divs
      Assert.greaterThan(uint(5010 finney),(d.s()).getDividends(address(a1)),"a1 should get time divs");
      Assert.greaterThan((d.s()).getDividends(address(a1)),uint(4990 finney),"a1 should get time divs");
      a1.unstake(1000); //unstake should return unstaked amount minus fee, also should not affect divs

      Assert.greaterThan(uint(5010 finney),(d.s()).getDividends(address(a1)),"a1 should get time divs");
      Assert.greaterThan((d.s()).getDividends(address(a1)),uint(4990 finney),"a1 should get time divs");
      Assert.equal(1000 ether,d.s().amountStaked(address(a1)),"a1 should have 1k staked at this stage");
    }



}
