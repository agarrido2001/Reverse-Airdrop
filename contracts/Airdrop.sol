// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title Reverse Airdrop.
 * @author Alejandro Garrido @xave.
 * @notice Make airdrops of a given ERC20 token, available to a list of accounts.
 * Instead of sending the tokens to every account, each account withdraws
 * its awarded tokens.
 */
contract Airdrop is AccessControlEnumerable {
    bytes32 public constant WHITELISTER_ROLE = keccak256("WHITELISTER_ROLE");

    // Token => whiteListed account => amount of tokens to be claimed.
    mapping(address => mapping(address => uint256)) private whiteListByToken;

    constructor() {
        // Set admin role to the deployer account.
        // Note that unlike grantRole, this function doesn’t perform any checks on the
        // calling account.
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /**
     * @notice Add/change a white list of accounts with the amount of tokens each
     * account can claim.
     * @param tokenAddress Token to assign the white list.
     * @param addressList List of accounts to add to the white list.
     * @param amountList List of amounts each account will be able to claim.
     * Assumes the index of amountList[i] corresponds to the same index of addressList[i].
     * @param overrideAmount If true, the old amount assigned to the account (if any)
     * will be overridden with the new amount. If false, the new amount will be added
     * to the previously assigned amount.
     */
    function addToWhiteList(
        address tokenAddress,
        address[] calldata addressList,
        uint256[] calldata amountList,
        bool overrideAmount
    ) public onlyRole(WHITELISTER_ROLE) {
        require(
            addressList.length == amountList.length,
            "Array arameters must be the samne size"
        );
        require(
            addressList.length > 0,
            "Array parameters must contain at least one item"
        );

        for (uint8 i; i < addressList.length; i++) {
            if (overrideAmount) {
                whiteListByToken[tokenAddress][addressList[i]] = amountList[i];
            } else {
                whiteListByToken[tokenAddress][addressList[i]] += amountList[i];
            }
        }
    }

    /**
     * @notice Add/change the claimable ammount of tolkens for one account on the white list
     * @param tokenAddress Token assigned to the white list.
     * @param accountAddress Account on the white list
     * @param amount Amount of tokens, accountAddress will be able to claim.
     * @param overrideAmt If true, the new amount will replace the old amount. If false, the
     * new amount will be added to the old amount
     */
    function addOnetoWhiteList(
        address tokenAddress,
        address accountAddress,
        uint256 amount,
        bool overrideAmt
    ) public onlyRole(WHITELISTER_ROLE) {
        require(amount > 0, "The amount cannot be zero.");
        if (overrideAmt) {
            whiteListByToken[tokenAddress][accountAddress] = amount;
        } else {
            whiteListByToken[tokenAddress][accountAddress] += amount;
        }
    }

    /**
     * @notice Reduce the amount of claimable tokens of one account on the white list.
     * @param tokenAddress Token assigned to the white list.
     * @param accountAddress Account from which claimable tokens will be subtracted.
     * @param amount Amount of tokens to subtract. It cannot be higher than current balance.
     */
    function subtractFromWhiteList(
        address tokenAddress,
        address accountAddress,
        uint256 amount
    ) public onlyRole(WHITELISTER_ROLE) {
        require(amount > 0, "The amount cannot be zero.");
        require(
            whiteListByToken[tokenAddress][accountAddress] >= amount,
            "The amount is to high"
        );
        whiteListByToken[tokenAddress][accountAddress] -= amount;
    }

    /**
     * @notice Get the claimable balance for one specific account.
     * @param tokenAddress Token assigned to the white list.
     * @param accountAddress Account to query.
     * @return amount Returns the balance. Zero also means it may have never been on
     * the white list.
     */
    function getWhiteListedClaimableBalance(
        address tokenAddress,
        address accountAddress
    ) public view onlyRole(WHITELISTER_ROLE) returns (uint256 amount) {
        return whiteListByToken[tokenAddress][accountAddress];
    }

    /**
     * @notice Returns the claimable amount of tokens. A user on the white list calls
     * this function to check its balance.
     * @param tokenAddress Token assigned to the white list.
     * @return amount Returns the balance. Zero also means the user may have never been
     * on the white list.
     */
    function getMyClaimableBalance(address tokenAddress)
        external
        view
        returns (uint256 amount)
    {
        return whiteListByToken[tokenAddress][msg.sender];
    }

    /**
     * @notice A user on the white list claims its tokens.
     * @param tokenOwner The account from which the tokens will be withdrawn.
     * @param tokenAddress Token assigned to the white list.
     * @param amount The ammount the user whishes to claim. It could be less than the
     * total claimable amount
     */
    function claimMyTokens(
        address tokenOwner,
        address tokenAddress,
        uint256 amount
    ) external {
        require(amount > 0, "The amount cannot be zero.");
        require(
            whiteListByToken[tokenAddress][msg.sender] != 0,
            "User not on the list"
        );
        require(
            whiteListByToken[tokenAddress][msg.sender] >= amount,
            "Not enough on user's claimable balance"
        );
        require(
            IERC20(tokenAddress).allowance(tokenOwner, address(this)) >= amount,
            "Need more allowance"
        );
        require(
            IERC20(tokenAddress).balanceOf(tokenOwner) >= amount,
            "The tokenOwner account does not have enough balance"
        );

        //Substracts the amount from user in whiteList
        whiteListByToken[tokenAddress][msg.sender] -= amount;

        //transfers the amount
        IERC20(tokenAddress).transferFrom(tokenOwner, msg.sender, amount);
    }
}
