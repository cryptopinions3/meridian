DEBUG=true
function main(){
    if(DEBUG){console.log('test')}
    refreshData()
    window.setInterval('refreshData()',2500)
}
function refreshData(){
  priceContract.methods.getPricePair(web3.utils.toWei("1",'ether'),"0x896a07e3788983ec52eaf0F9C6F6E031464Ee2CC","0x896a07e3788983ec52eaf0F9C6F6E031464Ee2CC","0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2").call().then(function(eth){
    priceContract.methods.getPricePair(eth,"0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2","0x6b175474e89094c44da98b954eedeac495271d0f","0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2").call().then(function(dollars){
      document.getElementById('priceDisplay').textContent=weiToDisplay(dollars)
    })
  })
}
function weiToDisplay(wei){
    return formatEthValue(web3.utils.fromWei(wei,'ether'))
}
function formatEthValue(ethstr){
    return parseFloat(parseFloat(ethstr).toFixed(2));
}
