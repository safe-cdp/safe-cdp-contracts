pragma solidity >=0.4.22 <0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SafeCDPFactory.sol";

contract TestSafeCDPFactory {

    function testCreateSafeCDP() public {
        SafeCDPFactory factory = SafeCDPFactory(DeployedAddresses.SafeCDPFactory());

        // Create two SafeCDPs
        address s1 = factory.createSafeCDP(bytes32(0));
        address s2 = factory.createSafeCDP(bytes32(uint(1)));

        Assert.equal(address(factory.ownerToSafeCDP(address(this), 0)), s1, "Expected 2 CDPs");
        Assert.equal(address(factory.ownerToSafeCDP(address(this), 1)), s2, "Expected 2 CDPs");
    }

}