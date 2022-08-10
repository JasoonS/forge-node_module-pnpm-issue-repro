// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

/**
@title SyntheticToken
@notice An ERC20 token that tracks or inversely tracks the price of an
        underlying asset with floating exposure.
@dev Logic for price tracking contained in LongShort.sol. 
     The contract inherits from ERC20PresetMinterPauser.sol
*/
contract SyntheticTokenOriginal is
    ERC20,
    ERC20Burnable,
    AccessControl,
    ERC20Permit
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @notice Address of the LongShort contract, a deployed LongShort.sol
    address public immutable longShort;
    /// @notice Address of the Staker contract, a deployed Staker.sol
    address public immutable staker;
    /// @notice Identifies which market in longShort the token is for.
    uint32 public immutable marketIndex;
    /// @notice Whether the token is a long token or short token for its market.
    bool public immutable isLong;

    /// @notice Creates an instance of the contract.
    /// @dev Should only be called by TokenFactory.sol for our system.
    /// @param name The name of the token.
    /// @param symbol The symbol for the token.
    /// @param _longShort Address of the core LongShort contract.
    /// @param _staker Address of the staker contract.
    /// @param _marketIndex Which market the token is for.
    /// @param _isLong Whether the token is long or short for its market.
    constructor(
        string memory name,
        string memory symbol,
        address _longShort,
        address _staker,
        uint32 _marketIndex,
        bool _isLong
    ) ERC20(name, symbol) ERC20Permit(name) {
        longShort = _longShort;
        staker = _staker;
        marketIndex = _marketIndex;
        isLong = _isLong;

        _setupRole(DEFAULT_ADMIN_ROLE, _longShort);
        _setupRole(MINTER_ROLE, _longShort);
    }

    /*╔══════════════════════════════════════════════════════╗
    ║    FUNCTIONS INHERITED BY ERC20PresetMinterPauser    ║
    ╚══════════════════════════════════════════════════════╝*/

    /** 
  @notice Overrides the default ERC20 transferFrom.
  @dev To allow users to avoid approving LongShort when redeeming tokens,
       longShort has a virtual infinite allowance.
  @param sender User for which to transfer tokens.
  @param recipient Recipient of the transferred tokens.
  @param amount Amount of tokens to transfer in wei.
  */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        if (recipient == longShort && msg.sender == longShort) {
            // If it to longShort and msg.sender is longShort don't perform additional transfer checks.
            ERC20._transfer(sender, recipient, amount);
            return true;
        } else {
            return ERC20.transferFrom(sender, recipient, amount);
        }
    }
}
