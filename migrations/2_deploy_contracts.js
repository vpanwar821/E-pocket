var EPTCrowdfund = artifacts.require("./EPTCrowdfund.sol");
var EPTToken = artifacts.require("./EPTToken.sol");

module.exports = function(deployer) {
 deployer.deploy(EPTCrowdfund,()=>{
   return deployer.deploy(EPTToken);
 });
};
