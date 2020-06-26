var DEBUG=true

var minbuy=1
var maxbuy=1000
var startTime=0

function main(){
    if(DEBUG){console.log('test')}
    refreshData()
    window.setInterval('refreshData()',2500)
    controlLoopFaster()
}
function controlLoopFaster(){
    //put faster update stuff here
    refreshTimers()
    setTimeout(controlLoopFaster,30)
}
function refreshData(){
  console.log('refreshdata called')
  document.getElementById('stakebutton').onclick=stake2;//LOCKStakeAmount
  document.getElementById('upgradebutton').onclick=upgradeTokens2;
  document.getElementById('unstakebutton').onclick=unStake2;
  document.getElementById('mintbuttonMRDN').onclick=mintMRDN;
  document.getElementById('mintbuttonLOCK').onclick=mintLOCK;
  document.getElementById('approvetoken').onclick=approve2;
  document.getElementById('withdrawDivs').onclick=withdrawDivs2;
  document.getElementById('reinvestDivs').onclick=reinvestDivs2;

  web3.eth.getAccounts(function (err, accounts) {
    let addr=accounts[0]
    oldEthAddress=addr
    tokenContractOld.methods.totalSupply().call().then(function(bal){
      document.getElementById('MRDNTotal').textContent=weiToDisplay(bal)
    })
    tokenContract.methods.totalSupply().call().then(function(bal){
      document.getElementById('LOCKTotal').textContent=weiToDisplay(bal)
    })
    tokenContractOld.methods.balanceOf(addr).call().then(function(bal){
      document.getElementById('MRDNBalance').textContent=weiToDisplay(bal)
      //disable upgrade button here if balance smaller than amount in input
    })
    tokenContract.methods.balanceOf(addr).call().then(function(bal){
      document.getElementById('LOCKBalance').textContent=weiToDisplay(bal)
      //disable stake button here if balance smaller than amount in input

    })
    tokenContract.methods.totalBurned().call().then(function(burned){
      document.getElementById('LOCKBurnedTotal').textContent=weiToDisplay(burned)
    })
    // add abi and uncomment when contract with this variable is deployed

    // tokenContract.methods.totalBurned().call().then(function(burned){
    //   document.getElementById('LOCKBurnedTotal').textContent=weiToDisplay(burned)
    // })
    stakingContract.methods.stakedTotalSum().call().then(function(staked){
      document.getElementById('LOCKStaked').textContent=weiToDisplay(staked)
    })
    stakingContract.methods.amountStaked(addr).call().then(function(staked){
      document.getElementById('LOCKStakedYours').textContent=weiToDisplay(staked)
    })
    stakingContract.methods.DIVIDEND_RATE().call().then(function(divr){
      document.getElementById('LOCKDivRate').textContent=divr/10+'%'
    })
    stakingContract.methods.BURN_RATE().call().then(function(divr){
      document.getElementById('LOCKBurnRate').textContent=divr/10+'%'
    })
    stakingContract.methods.getDividends(addr).call().then(function(divs){
      document.getElementById('yourdivs').textContent=weiToDisplay(divs)
    })
  })
}
function refreshTimers(){
  var nowtime=new Date().getTime()/1000
  if(nowtime>startTime){
  }
  else{
    setTimerFromSeconds(Number(startTime)-nowtime)
  }
}
function disableButton(buttonId){
  //console.log('placeholder, button disabled ',buttonId)
  document.getElementById(buttonId).disabled=true
}
function enableButton(buttonId){
  //console.log('placeholder, button enabled ',buttonId)
  document.getElementById(buttonId).disabled=false
}
function setTimerFromSeconds(seconds){
  var days        = Math.floor(seconds/24/60/60);
  var hoursLeft   = Math.floor((seconds) - (days*86400));
  var hours       = Math.floor(hoursLeft/3600);
  var minutesLeft = Math.floor((hoursLeft) - (hours*3600));
  var minutes     = Math.floor(minutesLeft/60);
  var remainingSeconds = seconds % 60;
  setTimer(days,hours,minutes,remainingSeconds)
}
function setTimer(days,hours,minutes,seconds){
  // document.getElementById('days').textContent=days
  // document.getElementById('hours').textContent=hours
  // document.getElementById('minutes').textContent=minutes
  // document.getElementById('seconds').textContent=seconds.toFixed(2)
}
function weiToDisplay(wei){
    return formatEthValue(web3.utils.fromWei(wei,'ether'))
}
function formatEthValue(ethstr){
    return parseFloat(parseFloat(ethstr).toFixed(2));
}
function upgradeTokens2(){
  if(DEBUG){console.log('upgrade tokens')}
  let tospend=web3.utils.toWei(document.getElementById('upgradeAmount').value,'ether')
  if(Number(tospend)>0){
      web3.eth.getAccounts(function (err, accounts) {
        address=accounts[0]
        upgradeContract.methods.upgrade(tospend).send({from:address}).then(function(){
          if(DEBUG){console.log('upgrade transaction sent')}
        })
      })
  }
}
function unStake2(){
  if(DEBUG){console.log('staking')}
  let tospend=web3.utils.toWei(document.getElementById('LOCKUnStakeAmount').value,'ether')//document.getElementById('LOCKUnStakeAmount').value
  if(Number(tospend)>0){
      web3.eth.getAccounts(function (err, accounts) {
        address=accounts[0]
        stakingContract.methods.unstake(tospend).send({from:address}).then(function(){
          if(DEBUG){console.log('unstaking transaction sent')}
        })
      })
  }
}
function stake2(){
  if(DEBUG){console.log('staking')}
  let tospend=web3.utils.toWei(document.getElementById('LOCKStakeAmount').value,'ether')//document.getElementById('LOCKStakeAmount').value
  if(Number(tospend)>0){
      web3.eth.getAccounts(function (err, accounts) {
        address=accounts[0]
        stakingContract.methods.stake(tospend).send({from:address}).then(function(){
          if(DEBUG){console.log('staking transaction sent')}
        })
      })
  }
}
function withdrawDivs2(){
  if(DEBUG){console.log('withdrawDivs2')}
  web3.eth.getAccounts(function (err, accounts) {
    address=accounts[0]
    stakingContract.methods.withdrawDivs().send({from:address}).then(function(){
      if(DEBUG){console.log('dividends withdraw')}
    })
  })
}
function reinvestDivs2(){
  if(DEBUG){console.log('reinvestDivs2')}
  web3.eth.getAccounts(function (err, accounts) {
    address=accounts[0]
    stakingContract.methods.reinvestDivs().send({from:address}).then(function(){
      if(DEBUG){console.log('dividends reinvest')}
    })
  })
}
function mintMRDN(){
  if(DEBUG){console.log('testmintMRDN')}
  web3.eth.getAccounts(function (err, accounts) {
    address=accounts[0]
    tokenContractOld.methods._mint(address,web3.utils.toWei("10000",'ether')).send({from:address}).then(function(err,result){
      if(DEBUG){console.log('testmint')}
    })
  })
}
function mintLOCK(){
  if(DEBUG){console.log('testmintLOCK')}
  web3.eth.getAccounts(function (err, accounts) {
    address=accounts[0]
    tokenContract.methods._mint(address,web3.utils.toWei("10000",'ether')).send({from:address}).then(function(err,result){
      if(DEBUG){console.log('testmint')}
    })
  })
}
function approve2(){
  if(DEBUG){console.log('approve2')}
  web3.eth.getAccounts(function (err, accounts) {
    address=accounts[0]
    //document.getElementById('approvewaitingtransaction').style.display="inline-block";
    tokenContractOld.methods.approve(upgradeContractAddress,web3.utils.toWei("100000000",'ether')).send({from:address}).then(function(err,result){
      if(DEBUG){console.log('approve')}
    })
  })
}
