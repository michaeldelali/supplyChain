App = {
  web3Provider: null,
  contracts: {},
  account:'0x0',

  init: async function() {  
    return await App.initWeb3();
  },

  initWeb3: async function() {
  if (typeof web3 !== "undefined"){
    //if a web3 instance is already provided by meta Mask.
    App.web3Provider = web3.currentProvider;
    web3 =new Web3(web3.currentProvider);
  }else {
    //specify default instance if no web3 instance provided
    App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
    web3 = new Web3(App.web3Provider);
  } 
    return App.initContract();
  },

 

  initContract: function() {
    $.getJSON("supplyChain.json",function(supplyChain) {
      //Instantiate anew truffle contract from the artifact
      App.contracts.supplyChain = TruffleContract(supplyChain);
      //Connect provider to interact with contract
      App.contracts.supplyChain.setProvider(App.web3Provider);

      App.listenforEvents();

      return App.render();
    });
  },

  // Listen for events emitted from the contract
  listenForEvents: function() {
    App.contracts.supplyChain.deployed().then(function(instance) {
      // Restart Chrome if you are unable to receive this event
      // This is a known issue with Metamask
      // https://github.com/MetaMask/metamask-extension/issues/2393
      instance.StepCreated({}, {
        fromBlock: 0,
        toBlock: 'latest'
      }).watch(function(error, event) {
        console.log("event triggered", event)
        // Reload when a new vote is recorded
        App.render();
      });
    });
  },


  render: function(){
    let account = web3.eth.getAccounts();
    var supply;
    var loader = $("#loader");
    var content = $("#content");

    console.log(supply);
    loader.show();
    content.hide();

    web3.eth.getCoinbase(function(err,account){
      if (err === null){
        App.account = account;
        $("#address").html("Your Account: "+ account);
      } 

    });

  //load contract data
  App.contracts.supplyChain.deployed().then(function(instance){
    supply =instance;
    return supply.newStep();
  }).then(function(item,precedent){
    var item = $("inputItem");
    item.empty();
    var precedent =$("precedingStep");
    precedent.empty();
    console.log("PUSHED");
    return supply.islastStep();
  }).then(function( _step){
    var _step = $("isLastStep");
    precedent.empty();
    console.log(islastStep(_step));
    return supply.getPrecedent();
  }).then(function(_step){
    var _step = $("getprecedent");
    precedent.empty();
    console.log(getPrecedent(_step));
  })
    

    


  }

  // //Listen for events emmited from the contract
  // listenforEvents: function(){
  //   App.contracts.supplyChain.deployed().then(function(instance){

  //   })
  // }

 

};

$(function() {
  $(window).load(function() { 
    App.init();
  });
});
