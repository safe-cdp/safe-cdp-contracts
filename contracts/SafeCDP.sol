pragma solidity >=0.4.21 <0.6.0;

import "ds-thing/thing.sol";

contract SafeCDP is DSThing {

    address actualOwner;

    modifier onlyActualOwner() {
        require(msg.sender == actualOwner, "not actual owner");
        _;
    }


    // These functions are the tub functions that can only be invoked by
    // the CDP owner.  Since this contract will technically be the CDP owner,
    // we need to expose these functions so the actual owner can still use
    // them.
    function give(bytes32 cup, address guy) public note onlyActualOwner { }
    function free(bytes32 cup, uint wad) public note onlyActualOwner { }
    function draw(bytes32 cup, uint wad) public note onlyActualOwner { }
    function shut(bytes32 cup) public note onlyActualOwner { }

    // When the collateralization ratio is lower than the margin call
    // threshold, this function may be invoked by a keeper to wipe enough
    // debt to raise the threshold to the target.
    function marginCall() public note { }
    
    // When invoked, the msg.sender will pay all the keepers that have covered
    // debt for this CDP.
    function respondToMarginCall() public note { }

    // A keeper may call this function to withdraw part of the collateral if
    // the CDP owner fails to respond to a margin call.
    function withdrawCollateral(uint wad) public note { }
}