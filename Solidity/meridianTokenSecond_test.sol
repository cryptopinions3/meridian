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
        token.stakingContract().activateContract();
        //staking.burnAfterContractEnd();
        token.transfer(address(token.stakingContract()),1000 ether);
        a1=new Actor(IERC(token),IStake(token.stakingContract()));
        a2=new Actor(IERC(token),IStake(token.stakingContract()));
        a3=new Actor(IERC(token),IStake(token.stakingContract()));
    }
    function testStake() public{
      a1.stake(1000 ether);
      a2.stake(2000 ether);
      Assert.equal(4000 ether,token.balanceOf(token.stakingContract()),"token balance should be equal");
      a2.unstake(2000 ether);
      a2.withdrawDivs();
      a1.withdrawDivs();
    }
    function testTimeWithdraw() public{
      Assert.equal(uint(0),token.stakingContract().getDividends(address(a1)),"a1 should not have divs here");
      Assert.equal(uint(0),token.stakingContract().getDividends(address(a2)),"a2 should not have divs here");
      token.stakingContract().setNowTest(startTime+12 hours);
      //emit Print(token.stakingContract().getDividends(address(a1)),"dividends after 12 hours a1");
      //1k finney = 1 eth, looking for 5 (starts 1k, half of 1%)
      Assert.greaterThan(uint(5010 finney),(token.stakingContract()).getDividends(address(a1)),"a1 should get time divs");
      Assert.greaterThan((token.stakingContract()).getDividends(address(a1)),uint(4990 finney),"a1 should get time divs");
      a1.stake(1000); //update checkpoint and change staked balance, this should not affect divs
      Assert.greaterThan(uint(5010 finney),(token.stakingContract()).getDividends(address(a1)),"a1 should get time divs");
      Assert.greaterThan((token.stakingContract()).getDividends(address(a1)),uint(4990 finney),"a1 should get time divs");
    }

    function testDivLimit() public{
      token.stakingContract().disableDividendAccumulationSpecific(startTime+12 hours);
      token.stakingContract().setNowTest(startTime+5 days);
      //divs should not have changed, despite time being days later, because of the accumulation limit being set 
      Assert.greaterThan(uint(5010 finney),(token.stakingContract()).getDividends(address(a1)),"a1 should get time divs");
      Assert.greaterThan((token.stakingContract()).getDividends(address(a1)),uint(4990 finney),"a1 should get time divs");

    }

    function checkSuccess() public {
        // Use 'Assert' to test the contract,
        // See documentation: https://remix-ide.readthedocs.io/en/latest/assert_library.html
        Assert.equal(uint(2), uint(2), "2 should be equal to 2");
        Assert.notEqual(uint(2), uint(3), "2 should not be equal to 3");
    }

    function checkSuccess2() public view returns (bool) {
        // Use the return value (true or false) to test the contract
        return true;
    }

}
