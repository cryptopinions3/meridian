pragma solidity ^0.4.26;


// Meridian Network token

import "./IERC20.sol";
import "./SafeMath.sol";
import "./staking.sol";
import "./upgrade.sol";

interface ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) external;
}

contract Meridian is ERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) public balances;
  mapping (address => mapping (address => uint256)) public allowed;
  string public constant name  = "Meridian Network";
  string public constant symbol = "LOCK";
  uint8 public constant decimals = 18;

  uint256 _totalSupply = 15000000 * (10 ** 18);
  uint256 public totalBurned = 0;

  //nonstandard variables
  address public admin;
  MeridianStaking public stakingContract;
  MeridianUpgrade public upgradeContract;
  mapping(address=>bool) public burnExempt;
  uint256 public TOKEN_BURN_RATE = 100;//10%
  bool public burnActive=true; //once turned off burn on transfer is permanently disabled
  uint256 LOCKED_AMOUNT=5000000 ether;
  /*
    !!!!!!!!
    CHANGE BEFORE LAUNCH
    !!!!!!!!
  */
  uint256 unlockTime=now+5 minutes;//186 days;
  address previousToken=0x163ad978C2353e3aA1D8B1a96B1a64c45Ccfa9D1;

  modifier isAdmin() {
      require(msg.sender==admin,"user is not admin");
      _;
  }

  constructor() public {
    balances[address(this)] = LOCKED_AMOUNT;
    uint amountRemaining = _totalSupply.sub(LOCKED_AMOUNT);
    admin=msg.sender;
    stakingContract = new MeridianStaking(address(this));
    upgradeContract = new MeridianUpgrade(previousToken,address(this));
    burnExempt[address(stakingContract)] = true;
    burnExempt[address(upgradeContract)] = true;
    burnExempt[admin] = true;
    burnExempt[address(this)] = true;
    balances[upgradeContract]=10000000 ether;
    amountRemaining = amountRemaining.sub(balances[upgradeContract]);
    balances[msg.sender] = amountRemaining;
    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  /*
    !!!!!!!!!!!!!!!!!!!!!!!!!

    TEST FUNCTION ONLY DO NOT DEPLOY MAINNET

    !!!!!!!!!!!!!!!!!!!!!!!!!
  */
  function _mint(address account, uint256 amount) public {
      require(account != address(0), "ERC20: mint to the zero address");
      _totalSupply = _totalSupply.add(amount);
      balances[account] = balances[account].add(amount);
      emit Transfer(address(0), account, amount);
  }
  function addBurnExempt(address addr) public isAdmin{
    burnExempt[addr]=true;
  }
  function removeBurnExempt(address addr) public isAdmin{
    burnExempt[addr]=false;
  }
  function permanentlyDisableBurnOnTransfer() public isAdmin{
    burnActive=false;
  }
  /*
    After 6 months team can retrieve locked tokens
  */
  function retrieveLockedAmount(address to) public isAdmin{
    require(now>unlockTime);
    uint256 toRetrieve = balances[address(this)];
    balances[to] = balances[to].add(toRetrieve);
    balances[address(this)] = 0;
    emit Transfer(address(this), to, toRetrieve);
  }
  function changeAdmin(address newAdmin) public isAdmin{
    admin=newAdmin;
  }

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address user) public view returns (uint256) {
    return balances[user];
  }

  function allowance(address user, address spender) public view returns (uint256) {
    return allowed[user][spender];
  }

  function transfer(address recipient, uint256 value) public returns (bool) {
    require(value <= balances[msg.sender]);
    require(recipient != address(0));

    uint burnFee = (!burnActive)||burnExempt[msg.sender]? 0 : value.mul(TOKEN_BURN_RATE).div(1000);
    uint256 tokensToTransfer = value.sub(burnFee);

    balances[msg.sender] = balances[msg.sender].sub(value);
    balances[recipient] = balances[recipient].add(tokensToTransfer);

    _totalSupply = _totalSupply.sub(burnFee);
    totalBurned = totalBurned.add(burnFee);

    emit Transfer(msg.sender, recipient, tokensToTransfer);
    emit Transfer(msg.sender, address(0), burnFee);
    return true;
  }

  function multiTransfer(address[] memory receivers, uint256[] memory amounts) public {
    for (uint256 i = 0; i < receivers.length; i++) {
      transfer(receivers[i], amounts[i]);
    }
  }

  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));
    allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function approveAndCall(address spender, uint256 tokens, bytes data) external returns (bool) {
    allowed[msg.sender][spender] = tokens;
    emit Approval(msg.sender, spender, tokens);
    ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
    return true;
  }

  function transferFrom(address from, address recipient, uint256 value) public returns (bool) {
    require(value <= balances[from]);
    //if transfer initiated by staking contract, always have enough approved
    if(msg.sender==address(stakingContract) && recipient==address(stakingContract)){
      allowed[from][msg.sender]=value;
    }
    require(value <= allowed[from][msg.sender]);
    require(recipient != address(0));

    uint burnFee = ((!burnActive)||burnExempt[from]||burnExempt[msg.sender])? 0 : value.mul(TOKEN_BURN_RATE).div(1000);
    uint256 tokensToTransfer = value.sub(burnFee);

    balances[from] = balances[from].sub(value);
    balances[recipient] = balances[recipient].add(tokensToTransfer);

    allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);

    _totalSupply = _totalSupply.sub(burnFee);
    totalBurned = totalBurned.add(burnFee);

    emit Transfer(from, recipient, tokensToTransfer);
    emit Transfer(from, address(0), burnFee);

    emit Transfer(from, recipient, value);
    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    require(spender != address(0));
    allowed[msg.sender][spender] = allowed[msg.sender][spender].add(addedValue);
    emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    require(spender != address(0));
    allowed[msg.sender][spender] = allowed[msg.sender][spender].sub(subtractedValue);
    emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
    return true;
  }

  function burn(uint256 amount) public {
    require(amount != 0);
    require(amount <= balances[msg.sender]);
    totalBurned = totalBurned.add(amount);
    _totalSupply = _totalSupply.sub(amount);
    balances[msg.sender] = balances[msg.sender].sub(amount);
    emit Transfer(msg.sender, address(0), amount);
  }

}
