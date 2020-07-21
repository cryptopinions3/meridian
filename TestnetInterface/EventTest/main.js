DEBUG=true
function main(){
    if(DEBUG){console.log('test')}
    refreshData()
    window.setInterval('refreshData()',2500)
}
function refreshData(){
  //csup
  processEvents()
}
function processEvents(){
  stakingContract.getPastEvents("WithdrawDivs",{ fromBlock: 0, toBlock: 'latest' },function(error,events){
    var totalWithdrawn=0
    events.forEach(function(eventResult){
      if (error)
        console.log('Error in myEvent event handler: ' + error);
      else
        //console.log('myEvent: ' + JSON.stringify(eventResult.returnValues));
        totalWithdrawn+=Number(web3.utils.fromWei(eventResult.returnValues.amount,'ether'))
    })
    document.getElementById('wdivs').textContent=totalWithdrawn.toFixed(2)
  });
}
function weiToDisplay(wei){
    return formatEthValue(web3.utils.fromWei(wei,'ether'))
}
function formatEthValue(ethstr){
    return parseFloat(parseFloat(ethstr).toFixed(2));
}
