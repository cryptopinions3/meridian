pragma solidity ^0.4.26;

import "./IERC20.sol";
import "./SafeMath.sol";

contract MeridianInterface is ERC20{
  function admin() external returns(address);
}

contract MeridianStaking{
  using SafeMath for uint;
  MeridianInterface public meridianToken;
  mapping(address => uint256) public amountStaked;
  mapping(address => int256) public payoutsTo;//only represents the portion of payouts from collective dividends
  mapping(address => uint256) public payoutsToTime;//over time related payouts
  mapping(address => uint256) public unclaimedDividends;//dividends over time before the last user checkpoint
  mapping(address => uint256) public dividendCheckpoints;//the time from which to calculate new dividends
  mapping(address => uint256) public dividendRateUsed;//
  uint256 public stakedTotalSum;
  uint256 public divsPerShare;
  uint256 constant internal magnitude = 2 ** 64;
  uint256 constant internal STAKING_MINIMUM = 1 ether; //token is 18 decimals
  uint256 public STAKING_PERIOD = 31 days; //time period to which the dividend rate refers to
  uint256 public BURN_RATE = 100; //1.0x multiplier for transaction burning
  uint256 public DIVIDEND_RATE = 15; //1.5%
  uint256 public UNSTAKE_RATE = 20; //20%
  bool public activated = false;

  event Stake(address indexed user, uint256 amount);
	event UnStake(address indexed user, uint256 amount);
  event WithdrawDivs(address indexed user, uint256 amount);
  event ReStakeDivs(address indexed user, uint256 amount);

  modifier isAdmin() {
      require(msg.sender==meridianToken.admin(),"user is not admin");
      _;
  }
  modifier isActive() {
      require(activated,"staking is not yet active");
      _;
  }

  constructor(address token) public{
    meridianToken=MeridianInterface(token);
  }
  function setRates(uint burn,uint div,uint unstake) public isAdmin{
    BURN_RATE=burn;
    DIVIDEND_RATE=div;
    UNSTAKE_RATE=unstake;
  }
  function activateContract() public isAdmin{
    activated=true;
  }
  function stake(uint256 amount) public{
    require(meridianToken.transferFrom(msg.sender,address(this),amount),"transfer failed");
    _stake(amount);
  }
  function _stake(uint256 amount) private isActive{
    require(amountStaked[msg.sender]+amount >= STAKING_MINIMUM,"amount below staking minimum");
    updateCheckpoint(msg.sender);
    stakedTotalSum = stakedTotalSum.add(amount);
    amountStaked[msg.sender] = amountStaked[msg.sender].add(amount);
    payoutsTo[msg.sender] = payoutsTo[msg.sender] + int256(amount * divsPerShare);
    emit Stake(msg.sender, amount);
  }
  //TODO: include rewards over time other than those from fees on all changes to staking
  function unstake(uint256 amount) public isActive{
    require(amountStaked[msg.sender] >= amount);
    updateCheckpoint(msg.sender);
    uint256 unstakeFee = amount.mul(UNSTAKE_RATE).div(100);
    divsPerShare = divsPerShare.add(unstakeFee.mul(magnitude.div(stakedTotalSum))); //TODO: burn a portion of this instead of all to divs
    stakedTotalSum = stakedTotalSum.sub(amount);
    uint256 taxedAmount = amount.sub(unstakeFee);
    amountStaked[msg.sender] = amountStaked[msg.sender].sub(amount);
    payoutsTo[msg.sender] -= int256(taxedAmount * divsPerShare);
    emit UnStake(msg.sender, amount);
  }
  function withdrawDivs() public{
    uint256 burnedDivs = getBurnedDivs(msg.sender);
    payoutsTo[msg.sender] += int256(burnedDivs * magnitude);//only use burnedDivs, since payoutsTo only pertains to these
    uint256 timeDivs=getTotalDivsOverTime(msg.sender);
    payoutsToTime[msg.sender] += timeDivs;
    uint256 divs=burnedDivs+timeDivs;
    meridianToken.transfer(msg.sender,divs);
    unclaimedDividends[msg.sender]=0;//since these have been transferred, set to zero
    emit WithdrawDivs(msg.sender, divs);
  }
  /*
  //UPDATE AFTER WITHDRAWDIVS IS DONE
  function reinvestDivs() public{
    uint256 divs = getDividends(msg.sender);
    payoutsTo[msg.sender] += int256(divs * magnitude);
    _stake(divs);
    emit ReStakeDivs(msg.sender, divs);
  }
  */
  function getDividends(address user) external view returns(uint256){
    return getBurnedDivs(user)+getTotalDivsOverTime(user);
  }
  function getBurnedDivs(address user) public view returns(uint256){
    require(int256(divsPerShare * amountStaked[user]) >= payoutsTo[user],"divs overflow");
    return uint256(int256(divsPerShare * amountStaked[user]) - payoutsTo[user]).div(magnitude);
  }
  function getBDTestInfo() external view returns(int,int,uint){
    address user=msg.sender;
    return (int256(divsPerShare * amountStaked[user]),int256(divsPerShare * amountStaked[user]) - payoutsTo[user],uint256(int256(divsPerShare * amountStaked[user]) - payoutsTo[user]));
  }
  function updateCheckpoint(address user) private{
    unclaimedDividends[user]+=getNewDivsOverTime(user);
    dividendCheckpoints[user]=now;
    dividendRateUsed[user]=DIVIDEND_RATE;//locks in latest div rate. Done after unclaimedDividends updated, so divs from before this operation will be at the old rate.
  }
  //recent divs over time plus previously recorded divs over time
  function getTotalDivsOverTime(address user) public view returns(uint256){
    return unclaimedDividends[user].add(getNewDivsOverTime(user)).sub(payoutsToTime[user]);
  }
  //Formula for dividends over time is (time_passed/staking_period)*staked_tokens*dividend_rate
  function getNewDivsOverTime(address user) public view returns(uint256){
    uint256 divRate=dividendRateUsed[user];
    return now.sub(dividendCheckpoints[user]).mul(amountStaked[user]).mul(dividendRateUsed[user]).div(STAKING_PERIOD.mul(1000));
  }
}
