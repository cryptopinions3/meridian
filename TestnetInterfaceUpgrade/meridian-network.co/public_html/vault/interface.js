//mainnet
// stakingContractAddress="0x79a77A695264543D601Bdefa03b0679C3E1cbdCD"
// upgradeContractAddress="0xE78a692FA69c063c54F3e94b76a50ec28FA2AC53"
// tokenContractAddress="0x95172ccBe8344fecD73D0a30F54123652981BD6F"
// oldTokenContractAddress="0x896a07e3788983ec52eaf0F9C6F6E031464Ee2CC"
// priceContractAddress="0xe2917ae98f323de2cf23f955146afb2d6811d771"

//testnet
stakingContractAddress="0x5E43903E5904373D0da08C8BA94482655F936619"//"0x0faEE8aB339d158652D8e31f71808b5F739082d5"//"0x19555F12b1ee558fCEE13Cc6BA17722410eE79fC"//"0xb50101EdE2Fd2E40b31ddFa8d69BD08a9aaDB117"//"0x96B66eDeB286e1Bc5fb0386f327441cAEc350F63"//"0x7326B3085d1C0f514679c6e02078aD02e51B8e74"//"0x66D5cbB0C8280541c718170732Af59F48E457651"//"0x7cE647fBD615EB98E79BB05d794368845B5B8E12"
upgradeContractAddress="0x196Ff45bc222c1270dDb7751E0804320B43EAB89"//"0xbc9d5B52f77C2b36054cAA4608828CeDa0f9Bac5"//+"0x4ef5971cB964bC32F1211cdCbfB09F8593b18A0E"
tokenContractAddress="0xb81Ee92F7D9e1c14C063FB2238dbA23508910484"//"0x462c8A8baD26A32c85a8DefEce63A73eCCf21d67"//"0x0024Cb4Eb7D7255f21a0AAbE34fc4b6b4b4DC9aD"//"0x41CC9124c412fE12D139276D7be390AD5CC2a69C"//"0x73E104e0424C7CDab0CDC65Da48c53c394052302"//"0x095032C17923C7CE45AA9cfbD452C52E5988fd46"//"0xC2093A90a4046B7F347c84f512651e6977BD11a0"//"0x00d8E49ebDefD8e5831E87C2d26a6513bfFd56a2"
oldTokenContractAddress="0x163ad978C2353e3aA1D8B1a96B1a64c45Ccfa9D1"//

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
      //if(ntype!='main'){
      if(ntype!='rinkeby'){
        //alert('please switch to mainnet in Metamask')
        alert('please switch to rinkeby in Metamask')
      }
    })
    window.upgradeContract=new web3.eth.Contract(upgradeAbi,upgradeContractAddress)
    window.stakingContract=new web3.eth.Contract(stakingAbi,stakingContractAddress)
		window.tokenContract=new web3.eth.Contract(tokenAbi,tokenContractAddress)
    window.tokenContractOld=new web3.eth.Contract(tokenAbi,oldTokenContractAddress)
    window.priceContract=new web3.eth.Contract(priceCheckAbi,priceContractAddress)
    console.log('calls main now')
		window.main()
  });
}
