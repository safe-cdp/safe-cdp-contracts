pragma solidity >=0.4.21 <0.6.0;

import "ds-thing/thing.sol";

contract SafeCDP is DSThing {

    address cdpOwner;
    address tub;
    bytes32 cup;

    modifier onlyCDPOwner() {
        require(msg.sender == cdpOwner, "Not CDP owner.");
        _;
    }

    // Making sure that this contract can only be used if the CDP has
    // actually been given to this contract.
    modifier ifCDPGiven() {
        require(this == tub.lad(cup), "This contract doesn't own the CDP.");
        _;
    }

    // Certain functions from the SaiProxy are priviledged, in that they can
    // only be invoked by the owner.
    // Since this contract is technically the owner of CDP, we need to expose
    // those functions here so clients (e.g. the CDP portal) can work with
    // minimal modifications.
    // TODO: implement those functions

    // When the collateralization ratio is lower than the margin call
    // threshold, this function may be invoked by a keeper to wipe enough
    // debt to raise the threshold to the target.
    function marginCall() public note ifCDPGiven { }
    
    // When invoked, the msg.sender will pay all the keepers that have covered
    // debt for this CDP.
    function respondToMarginCall() public note ifCDPGiven { }

    // A keeper may call this function to withdraw part of the collateral if
    // the CDP owner fails to respond to a margin call.
    function withdrawCollateral(uint _wad) public note ifCDPGiven { }

}