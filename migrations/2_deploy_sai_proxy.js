const SaiProxy = artifacts.require("SaiProxy")

module.exports = function (deployer) {
  deployer.deploy(SaiProxy)
}