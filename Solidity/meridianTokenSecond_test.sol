pragma solidity >=0.4.22 <0.7.0;
import "./IERC20.sol";
import "./SafeMath.sol";
import "./Interfaces.sol";
import "./meridianToken.sol";
//import "./staking.sol";
import "./Actor.sol";
import "./deploy.sol";

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
        IERC(d.m())._mint(address(this),1000000 ether);
        IERC(d.m()).addBurnExempt(address(this));
        IStake(d.s()).activateContract();
        IERC(d.m()).transfer(address(d.s()),1000 ether);
        a1=new Actor(IERC(d.m()),IStake(d.s()));
        a2=new Actor(IERC(d.m()),IStake(d.s()));
        a3=new Actor(IERC(d.m()),IStake(d.s()));
    }
    function testStake() public{
      a1.stake(1000 ether);
      a2.stake(2000 ether);
      Assert.equal(5004000 ether,IERC(d.m()).balanceOf(d.s()),"token balance should be equal");
      a2.unstake(2000 ether);
      a2.withdrawDivs();
      //emit Print(IStake(d.s()).getDividends(address(a1)),"dividends before withdraw a1");
      a1.withdrawDivs();
      //emit Print(IStake(d.s()).getDividends(address(a1)),"dividends after withdraw a1");
    }



}
