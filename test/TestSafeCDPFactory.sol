pragma solidity >=0.4.22 <0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SafeCDPFactory.sol";

contract TestSafeCDPFactory {

    // Test that the factory is able to create SafeCDPs and that it correctly
    // keeps track of the owner of the SafeCDPs.
    function testCreateSafeCDP() public {
        SafeCDPFactory factory = SafeCDPFactory(DeployedAddresses.SafeCDPFactory());

        // Create two SafeCDPs
        address s1 = factory.createSafeCDP(bytes32(0), 0, 0, 0, 0);
        address s2 = factory.createSafeCDP(bytes32(uint(1)), 0, 0, 0, 0);

        Assert.equal(address(factory.ownerToSafeCDP(address(this), 0)), s1, "Expected 2 CDPs");
        Assert.equal(address(factory.ownerToSafeCDP(address(this), 1)), s2, "Expected 2 CDPs");
    }

    // Test that the factory has the correct tub address, and that the tub is
    // in fact the correct tub.
    function testTubAddress() public {
        SafeCDPFactory factory = SafeCDPFactory(DeployedAddresses.SafeCDPFactory());
        TubInterface tub = TubInterface(factory.tub());
        Assert.equal(address(tub), 0xE82CE3D6Bf40F2F9414C8d01A35E3d9eb16a1761, "Incorrect address");
        Assert.equal(address(tub.sai()), 0xC226F3CD13d508bc319F4f4290172748199d6612, "Incorrect address");
    }

}