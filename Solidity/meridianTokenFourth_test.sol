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
      a1.withdrawDivs();

      d.s().setNowTest(startTime+12 hours);
      a1.stake(1000); //update checkpoint and change staked balance, this should not affect divs
      a1.unstake(1000);
    }

    function testDivRateChange() public{
      a2.stake(1000 ether);
      d.s().setNowTest(startTime+24 hours);//12 hours (previously set time) plus 12
      d.s().setRates(100,15,50);//set div rate to 1.5% instead of 1.0%
      //divs should be at the 1% rate still, since staked before change
      Assert.greaterThan(uint(5010 finney),(d.s()).getDividends(address(a2)),"a2 should get time divs1");
      Assert.greaterThan((d.s()).getDividends(address(a2)),uint(4990 finney),"a2 should get time divs2");
      a2.stake(1000 ether);//2000 total staked
      d.s().setNowTest(startTime+2 days);//add 1 day
      //should have earned divs on new rate, plus old divs. 1.5% of 2k = 30, plus 5
      Assert.greaterThan(uint(36 ether),(d.s()).getDividends(address(a2)),"a2 should get new rate time divs1");
      Assert.greaterThan((d.s()).getDividends(address(a2)),uint(34 ether),"a2 should get new rate time divs2");

    }
    function testDivLimit() public{
      d.s().disableDividendAccumulationSpecific(startTime+12 hours);
      d.s().setNowTest(startTime+5 days);
      //divs should not have changed, despite time being days later, because of the accumulation limit being set
      Assert.greaterThan(uint(5010 finney),(d.s()).getDividends(address(a1)),"a1 should get time divs");
      Assert.greaterThan((d.s()).getDividends(address(a1)),uint(4990 finney),"a1 should get time divs");

    }


}
