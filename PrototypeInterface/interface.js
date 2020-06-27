//mainnet
// stakingContractAddress=""
// upgradeContractAddress=""
// tokenContractAddress=""
// oldTokenContractAddress=""

//testnet
stakingContractAddress="0x7326B3085d1C0f514679c6e02078aD02e51B8e74"//"0x66D5cbB0C8280541c718170732Af59F48E457651"//"0x7cE647fBD615EB98E79BB05d794368845B5B8E12"
upgradeContractAddress="0x2945a1915850effcdc4A8a9EB7A23C6F0866A72d"//+"0x4ef5971cB964bC32F1211cdCbfB09F8593b18A0E"
tokenContractAddress="0x095032C17923C7CE45AA9cfbD452C52E5988fd46"//"0xC2093A90a4046B7F347c84f512651e6977BD11a0"//"0x00d8E49ebDefD8e5831E87C2d26a6513bfFd56a2"
oldTokenContractAddress="0x163ad978C2353e3aA1D8B1a96B1a64c45Ccfa9D1"//

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
      web3 = new Web3('wss://rinkeby.infura.io/ws');
      //web3 = new Web3('wss://mainnet.infura.io/ws');
      console.log('Non-Ethereum browser detected. You should consider trying MetaMask!');
    }
    web3.eth.net.getId().then(function(nid){
      window.netId=nid;
			console.log('netid ',window.netId)
    })
		console.log('should be checking network')
    web3.eth.net.getNetworkType().then(function(ntype){
      console.log('network ',ntype)
      //if(ntype!='main'){
      if(ntype!='rinkeby'){
        alert('please switch to rinkeby in Metamask')
        //alert('please switch to mainnet in Metamask')
      }
    })
    window.upgradeContract=new web3.eth.Contract(upgradeAbi,upgradeContractAddress)
    window.stakingContract=new web3.eth.Contract(stakingAbi,stakingContractAddress)
		window.tokenContract=new web3.eth.Contract(tokenAbi,tokenContractAddress)
    window.tokenContractOld=new web3.eth.Contract(tokenAbi,oldTokenContractAddress)
    console.log('calls main now')
		window.main()
  });
}
