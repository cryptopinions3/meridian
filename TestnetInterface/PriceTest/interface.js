
//mainnet
priceContractAddress="0xe2917ae98f323de2cf23f955146afb2d6811d771"

setup()
function setup(){
  window.addEventListener('load', async () => {
    // Modern dapp browsers...
    if (window.ethereum) {
      console.log('interface starting modern')
      window.web3 = new Web3(ethereum);
      try {
        // Request account access if needed
        await ethereum.enable();
        // Acccounts now exposed
        web3.eth.sendTransaction({/* ... */});
      } catch (error) {
        // User denied account access...
      }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
      console.log('legacydapp')
      window.web3 = new Web3(web3.currentProvider);
      // Acccounts always exposed
      web3.eth.sendTransaction({/* ... */});
    }
    // Non-dapp browsers...
    else {
      alert('please ensure https://metamask.io/ is installed and connected ')
      //web3 = new Web3('wss://rinkeby.infura.io/ws');
      web3 = new Web3('wss://mainnet.infura.io/ws');
      console.log('Non-Ethereum browser detected. You should consider trying MetaMask!');
    }
    web3.eth.net.getId().then(function(nid){
      window.netId=nid;
			console.log('netid ',window.netId)
    })
		console.log('should be checking network')
    web3.eth.net.getNetworkType().then(function(ntype){
      console.log('network ',ntype)
      if(ntype!='main'){
      //if(ntype!='rinkeby'){
        //alert('please switch to rinkeby in Metamask')
        alert('please switch to mainnet in Metamask')
      }
    })
    window.priceContract=new web3.eth.Contract(priceCheckAbi,priceContractAddress)
    console.log('calls main now')
		window.main()
  });
}
