pragma solidity >=0.4.22 <0.6.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

import "../contracts/DSMath.sol";
import "../contracts/SafeCDPFactory.sol";
import "../contracts/SafeCDP.sol";
import "../contracts/SaiProxy.sol";

contract TestSafeCDP is DSMath {

    // Test that a margin call fails if the CDP is not under the margin call
    // threshold.
    function testBadMarginCall() public {
        SafeCDPFactory factory = SafeCDPFactory(DeployedAddresses.SafeCDPFactory());
        TubInterface tub = TubInterface(factory.tub());
        SaiProxy sp = SaiProxy(factory.saiProxy());

        // Create a highly collateralized CDP
        uint targetCollateralization = 2 * RAY;
        uint marginCallThreshold = 18 * RAY / 10;
        uint marginCallDuration = 3 days;
        uint rewardForKeeper = 2 * RAY / 10;

        uint eth = 1 ether;
        uint dai = rdiv(rdiv(rmul(eth, tub.tag()), tub.vox().par()), targetCollateralization);

        bytes32 cup = sp.openAndLockAndDraw.value(eth)(address(tub), dai);

        SafeCDP safeCDP = SafeCDP(factory.createSafeCDP(
            cup,
            targetCollateralization,
            marginCallThreshold,
            marginCallDuration,
            rewardForKeeper));

        safeCDP.marginCall();
    }

}