const Loteria = artifacts.require("Loteria");

module.exports = function(deployer) {
  deployer.deploy(Loteria);
};
