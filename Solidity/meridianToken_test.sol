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
        // Here should instantiate tested contract
        Assert.equal(uint(1), uint(1), "1 should be equal to 1");
        d=new DeployMeridian();
        //token=new Meridian();
        IERC(d.m())._mint(address(this),1000000 ether);
        IERC(d.m()).addBurnExempt(address(this));
        IStake(d.s()).activateContract();
        IERC(d.m()).transfer(address(d.s()),1000 ether);
        a1=new Actor(IERC(d.m()),IStake(d.s()));
        a2=new Actor(IERC(d.m()),IStake(d.s()));
        a3=new Actor(IERC(d.m()),IStake(d.s()));
    }
    function testTokenBurn() public{
      //uint thisStart=IERC(d.m()).balanceOf(address(this));
      IERC(d.m()).transfer(address(a3),IERC(d.m()).balanceOf(address(this)));
      a3.transferTokens(address(this),1000 ether);
      Assert.greaterThan(uint(901 ether),IERC(d.m()).balanceOf(address(this)),"tokens should transfer minus 10% fee 1");
      Assert.greaterThan(IERC(d.m()).balanceOf(address(this)),uint(899 ether),"tokens should transfer minus 10% fee 2");
    }
    function testStake() public{
      a1.stake(1000 ether);
      a2.stake(2000 ether);
      Assert.equal(5004000 ether,IERC(d.m()).balanceOf(address(d.s())),"token balance should be equal");
      Assert.equal(8000 ether,IERC(d.m()).balanceOf(address(a2)),"a2 token balance should be reduced");
    }
    function testUnstake() public{
      a1.unstake(1000 ether);
    }


}
