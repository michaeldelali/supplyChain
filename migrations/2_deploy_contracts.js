var supplyChain = artifacts.require("./supplyChain.sol");
var admin = artifacts.require("./admin.sol");
var right = artifacts.require("./right.sol");
module.exports = function(deployer) {
  deployer.deploy(supplyChain);
  deployer.deploy(admin);
  deployer.deploy(right);
};
