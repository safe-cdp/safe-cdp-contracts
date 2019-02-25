pragma solidity >=0.4.22 <0.6.0;

import "./SafeCDP.sol";

contract SafeCDPFactory {

    address tub;

    // A mapping from the original CDP owner to the SafeCDPs they own.
    // In actuality, the original owner is probably a DSProxy.
    mapping(address => SafeCDP[]) public ownerToSafeCDP;

    constructor(address _tub) public {
        tub = _tub;
    }

    function createSafeCDP(bytes32 _cup) public returns (address) {
        SafeCDP s = new SafeCDP(msg.sender, tub, _cup);
        ownerToSafeCDP[msg.sender].push(s);
        return address(s);
    }

}