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
    function testTokenBurn() public{
      //uint thisStart=token.balanceOf(address(this));
      token.transfer(address(a3),token.balanceOf(address(this)));
      a3.transferTokens(address(this),1000 ether);
      Assert.greaterThan(uint(901 ether),token.balanceOf(address(this)),"tokens should transfer minus 10% fee 1");
      Assert.greaterThan(token.balanceOf(address(this)),uint(899 ether),"tokens should transfer minus 10% fee 2");

    }
    function testStake() public{
      a1.stake(1000 ether);
      a2.stake(2000 ether);
      Assert.equal(4000 ether,token.balanceOf(token.stakingContract()),"token balance should be equal");
      Assert.equal(8000 ether,token.balanceOf(address(a2)),"a2 token balance should be reduced");
    }
    function testBurnWithdraw() public{
      a2.unstake(2000 ether);
      //emit Print((token.stakingContract()).getDividends(address(a2)),"a2 divs");
      //emit Print((token.stakingContract()).getDividends(address(a1)),"a1 divs");
      Assert.greaterThan(uint(10000 ether),token.balanceOf(address(a2)),"a2 should not have more than what they started with");
      Assert.greaterThan(token.balanceOf(address(a2)),uint(9000 ether),"a2 should get back most");
      //between 33 and 34 tokens, 1/3 of 100 tokens distributed from 2000 unstake (5%)
      Assert.greaterThan(uint(34 ether),(token.stakingContract()).getDividends(address(a1)),"a1 should get divs");
      Assert.greaterThan((token.stakingContract()).getDividends(address(a1)),uint(33 ether),"a1 should get divs");
      Assert.greaterThan(uint(67 ether),(token.stakingContract()).getDividends(address(a2)),"a2 should get divs");
      Assert.greaterThan((token.stakingContract()).getDividends(address(a2)),uint(66 ether),"a2 should get divs");
      a1.stake(1000 ether); //update checkpoint and change staked balance, this should not affect divs
      Assert.greaterThan(uint(67 ether),(token.stakingContract()).getDividends(address(a2)),"a2 should get divs");
      Assert.greaterThan((token.stakingContract()).getDividends(address(a2)),uint(66 ether),"a2 should get divs");

      uint a1bal=token.balanceOf(address(a1));
      a1.withdrawDivs();
      uint a1bal2=token.balanceOf(address(a1));
      uint a1baldif=a1bal2-a1bal;
      //subtract 10% burn fee
      Assert.greaterThan(uint(31 ether),a1baldif,"a1 should get divs in tokens");
      Assert.greaterThan(a1baldif,uint(29 ether),"a1 should get divs in tokens");
    }


}
