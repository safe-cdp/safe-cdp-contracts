const SafeCDPFactory = artifacts.require("SafeCDPFactory")

module.exports = function (deployer, network) {
  let tub, dai;

  // The addresses are from this page:
  // https://developer.makerdao.com/dai/1/api/
  if (network === "kovan") {
    tub = "0xa71937147b55deb8a530c7229c442fd3f31b7db2"
    dai = "0xc4375b7de8af5a38a93548eb8453a498222c4ff2"
  } else if (network === "mainnet") {
    tub = "0x448a5065aebb8e423f0896e6c5d525c040f59af3"
    dai = "0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359"
  } else {
    // TODO: these are random addresses.  Use real ones.
    tub = "0xa71937147b55deb8a530c7229c442fd3f31b7db2"
    dai = "0xc4375b7de8af5a38a93548eb8453a498222c4ff2"
  }

  deployer.deploy(SafeCDPFactory, tub)
}