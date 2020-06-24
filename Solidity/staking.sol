pragma solidity ^0.4.26;

import "./IERC20.sol";
import "./SafeMath.sol";

contract MeridianStaking{
  using SafeMath for uint;
  ERC20 public meridianToken;
  mapping(address => uint256) public amountStaked;
  mapping(address => int256) public payoutsTo;
  mapping(address => uint256) public unclaimedDividends;
  uint256 public stakedTotalSum;
  uint256 public divsPerShare;
  uint256 constant internal magnitude = 2 ** 64;
  uint256 constant internal STAKING_MINIMUM = 1 ether; //token is 18 decimals
  uint256 public BURN_RATE = 100 //1.0x multiplier for transaction burning
  uint256 public DIVIDEND_RATE = 15 //1.5%
  uint256 public UNSTAKE_RATE = 20 //20%

  event Stake(address indexed user, uint256 amount);
	event UnStake(address indexed user, uint256 amount);
  event WithdrawDivs(address indexed user, uint256 amount);
  event ReStakeDivs(address indexed user, uint256 amount);

  modifier isAdmin() {
      require(msg.sender==meridianToken.admin(),"user is not admin");
      _;
  }

  constructor(address token) public{
    meridianToken=ERC20(token);
  }
  function setRates(uint burn,uint div,uint unstake) isAdmin{
    BURN_RATE=burn;
    DIVIDEND_RATE=div;
    UNSTAKE_RATE=unstake;
  }
  function stake(uint256 amount) public{
    require(meridianToken.transferFrom(msg.sender,address(this),amount));
    _stake(amount);
  }
  function _stake(uint256 amount) private{
    require(amountStaked[msg.sender]+amount >= STAKING_MINIMUM);
    stakedTotalSum = stakedTotalSum.add(amount);
    amountStaked[msg.sender] = amountStaked[msg.sender].add(amount);
    payoutsTo[msg.sender] = payoutsTo[msg.sender].add(int256(amount * divsPerShare));
    emit Stake(msg.sender, amount);
  }
  //TODO: include rewards over time other than those from fees on all changes to staking
  function unstake(uint256 amount) public{
    require(amountStaked[msg.sender] >= amount);
    uint256 unstakeFee = amount.mul(UNSTAKE_RATE).div(100);
    divsPerShare = divsPerShare.add(unstakeFee.mul(magnitude.div(stakedTotalSum))); //TODO: burn a portion of this instead of all to divs
    stakedTotalSum = stakedTotalSum.sub(amount);
    uint256 taxedAmount = amount.sub(unstakeFee);
    amountStaked[msg.sender] = amountStaked[msg.sender].sub(amount);
    payoutsTo[msg.sender] -= int256(taxedAmount * divsPerShare);
    emit UnStake(msg.sender, amount);
  }
  function withdrawDivs() public{
    uint256 divs = getDividends(msg.sender);
    payoutsTo[msg.sender] += int256(divs * magnitude);
    meridianToken.transfer(msg.sender,divs);
    emit WithdrawDivs(msg.sender, divs);
  }
  function reinvestDivs() public{
    uint256 divs = getDividends(msg.sender);
    payoutsTo[msg.sender] += int256(divs * magnitude);
    _stake(divs);
    emit ReStakeDivs(msg.sender, divs);
  }
  function getDividends(address user) public view returns(uint256){
    return uint256(int256(divsPerShare * amountStaked[user]) - payoutsTo[user]).div(magnitude);
  }
}
