pragma solidity >=0.4.22 <0.6.0;

import "./SafeCDP.sol";

contract SafeCDPFactory {

    // The tub (i.e. CDP Registry) contract
    address public tub;
    
    // The SaiProxy library contract
    address public saiProxy;

    // A mapping from the original CDP owner to the SafeCDPs they own.
    // In actuality, the original owner is probably a DSProxy.
    mapping(address => SafeCDP[]) public ownerToSafeCDP;

    constructor(address _tub, address _saiProxy) public {
        tub = _tub;
        saiProxy = _saiProxy;
    }

    function createSafeCDP(
        bytes32 _cup,
        uint _targetCollateralization,
        uint _marginCallThreshold,
        uint _marginCallDuration,
        uint _rewardForKeeper
    ) public returns (address) {
        SafeCDP s = new SafeCDP(
            tub, saiProxy, msg.sender, _cup,
            _targetCollateralization,
            _marginCallThreshold,
            _marginCallDuration,
            _rewardForKeeper);
        ownerToSafeCDP[msg.sender].push(s);
        return address(s);
    }

}