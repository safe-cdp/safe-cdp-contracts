pragma solidity >=0.4.22 <0.6.0;

import "./DSMath.sol";

contract TokenInterface {
    function allowance(address, address) public view returns (uint);
    function balanceOf(address) public view returns (uint);
    function approve(address, uint) public;
    function transfer(address, uint) public returns (bool);
    function transferFrom(address, address, uint) public returns (bool);
    function deposit() public payable;
    function withdraw(uint) public;
    function burn(address, uint) public;
}

contract VoxInterface {
    function par() public returns (uint);
}

contract TubInterface {
    VoxInterface public vox;  // Target price feed
    function sai() public view returns (TokenInterface);
    function lad(bytes32 cup) public view returns (address);
    function tab(bytes32 cup) public view returns (uint);
    function tag() public view returns (uint wad);
    function ink(bytes32 cup) public view returns (uint);
}

contract SafeCDP is DSMath {

    TubInterface tub;
    address saiProxy;
    TokenInterface token;
    address cdpOwner;
    bytes32 cup;

    uint targetCollateralization;
    uint marginCallThreshold;
    uint marginCallDuration;
    uint rewardForKeeper;

    // Mapping from keeper to the amount of debt they paid
    mapping(address => uint) public balances;
    // The total amount of debt paid for by keepers
    uint totalBalance;

    modifier onlyCDPOwner() {
        require(msg.sender == cdpOwner, "Not CDP owner.");
        _;
    }

    // Making sure that this contract can only be used if the CDP has
    // actually been given to this contract.
    modifier ifCDPGiven() {
        require(address(this) == tub.lad(cup), "This contract doesn't own the CDP.");
        _;
    }

    constructor(
        address _tub,
        address _saiProxy,
        address _cdpOwner,
        bytes32 _cup,
        uint _targetCollateralization,
        uint _marginCallThreshold,
        uint _marginCallDuration,
        uint _rewardForKeeper) public {

        tub = TubInterface(_tub);
        saiProxy = _saiProxy;
        token = tub.sai();
        cdpOwner = _cdpOwner;
        cup = _cup;
        targetCollateralization = _targetCollateralization;
        marginCallThreshold = _marginCallThreshold;
        marginCallDuration = _marginCallDuration;
        rewardForKeeper = _rewardForKeeper;
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
    function marginCall() public ifCDPGiven {
        uint debtToPay = diffWithTargetCollateral();
        // rewardForKeeper is a decimal in wad, like 0.2
        uint additionalBalance = debtToPay * (WAD + rewardForKeeper) / WAD;

        balances[msg.sender] += additionalBalance;
        totalBalance += additionalBalance;

        // Here we assume that the msg.sender (which is the keeper) has
        // approved `debtToPay` amount of DAI for us.
        (bool success, ) = saiProxy.delegatecall(abi.encodeWithSignature("wipe(address,bytes32,uint)", tub, cup, debtToPay));

        require(success, "failed to wipe debt");
    }
    
    // When invoked, the msg.sender will pay all keepers that have covered
    // debt for this CDP.
    //
    // Note that it would be insecure for the msg.sender to pay all keepers
    // one by one, as it risks running out of gas and the keepers being
    // malicious smart contracts.  Therefore, we simply transfer funds
    // to this contract, and let the keepers claim rewards themselves.
    function payBalance() public ifCDPGiven {
        // effects
        uint toTransfer = totalBalance;
        totalBalance = 0;

        // interactions
        token.transferFrom(msg.sender, address(this), toTransfer);
    }

    function claimBalance() public ifCDPGiven {
        // checks
        uint toTransfer = balances[msg.sender];
        require(toTransfer > 0, "no outstanding balance");

        // effects
        balances[msg.sender] = 0;

        // interactions
        token.transferFrom(address(this), msg.sender, toTransfer);
    }

    // A keeper may call this function to withdraw part of the collateral if
    // the CDP owner fails to respond to a margin call.
    function withdrawCollateral(uint _wad) public ifCDPGiven { }

    // The amount of debt that needs to be paid to bring the collateralization
    // ratio to the target.
    function diffWithTargetCollateral() public returns (uint) {
        uint con = rmul(tub.vox().par(), wadToRay(tub.tab(cup)));
        uint pro = rmul(tub.tag(), wadToRay(tub.ink(cup)));
        return rayToWad(sub(con, rdiv(pro, targetCollateralization)));
    }

    // MakerDAO's contracts use DSMath, which introduces two decimal types
    // known as wad and ray.  wad has 18 digits of precision and ray has 27.
    //
    // These are helper functions for converting between ray and wad.
    function wadToRay(uint wad) public pure returns (uint) {
        return wad * (RAY/WAD);
    }

    function rayToWad(uint ray) public pure returns (uint) {
        return ray / (RAY/WAD);
    }

}