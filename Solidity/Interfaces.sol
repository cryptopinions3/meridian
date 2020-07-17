contract IStake{
  function stake(uint256 amount) public;
  function unstake(uint256 amount) public;
  function withdrawDivs() public;
  function reinvestDivs() public;
  function getDividends(address user) external view returns(uint256);
  function getBurnedDivs(address user) external view returns(uint256);
  function getTotalDivsOverTime(address user) external view returns(uint256);
  function getNewDivsOverTime(address user) external view returns(uint256);
  function getTotalDivsSubWithdrawFee(address user) external view returns(uint256);
  function activateContract() public;
  function burnAfterContractEnd() public;
  function setNowTest(uint256 newNow) public;
  function disableDividendAccumulationSpecific(uint256 endTime) public;
  function amountStaked(address a) public view returns(uint256);
}
contract IUpgrade{
  function upgrade(uint amount) external;
}
contract IERC {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function approveAndCall(address spender, uint256 tokens, bytes data) external returns (bool);
    function _mint(address account, uint256 amount) public;
    function addBurnExempt(address addr) public;

}
