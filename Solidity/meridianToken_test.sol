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

    function checkFailure() public {
        Assert.equal(uint(1), uint(2), "1 is not equal to 2");
    }
}
