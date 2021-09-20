<img src="https://kepler.gomusiclive.com/assets/xavemarket/artists/xavemarket-artist.jpg" alt="https://kepler.gomusiclive.com/assets/xaveproject/artists/xavemarket-artist.jpg"  width=120 align=left />


## Official Xave Project public repository

www.xavecoin.com / hello@xavecoin.com

To validate the authenticity of this repository, please send an email to the official project's mailbox above with the current URL on the body.

---

# Reverse Airdrop

## Purpose
Make airdrops of a given ERC20 token, available to a list of accounts.
Instead of sending the tokens to every account, each account withdraws its awarded tokens.  
When they retrieve those tokens, they pay for the gas needed for the transaction.
 
A user with WHITELISTER_ROLE access, creates a white list with the
amount of tokens to reward each account.
 
The white list contains the ERC20 token address. Therefore, Airdrop can handle multiple airdrops for multiple tokens.
 
For each token, a token holder must approve Airdrop to transfer
tokens on its behalf.
 
 
## Calling Airdrop's functions
 
 
The following list represents roles that one or more users play in the process.
 
- <ins>airdropDeployer</ins>: account deploying the Airdrop contract.
- <ins>newAdminRoleAcc</ins>: airdropDeployer may grant DEFAULT_ADMIN_ROLE to another account.
- <ins>whiteLister</ins>: account with rights to add or change the white list.
- <ins>tokenOwner</ins>: account from which tokens will be withdrawn by the claimer.
- <ins>claimer</ins>: account that claims the rewarded tokens.
 
 
### Grant rights to Airdrop
<ins>tokenOwner</ins> grants rights to Airdrop contract to transfer tokens on its behalf.
 
```
await myToken.approve(airdrop.address, amount);
```
 
### Check allowance
Anyone could check how much allowance is left on Airdrop to transfer tokens.
```
amtLeft = await myToken.allowance(tokenOwner, airdrop.address )
 
```
 
### Grant admin role
<ins>airdropDeployer</ins> grants admin role to <ins>newAdminRoleAcc</ins>.
```
await airdrop.grantRole(airdrop.DEFAULT_ADMIN_ROLE(), newAdminRoleAcc);
```
 
### Grant whitelister role
<ins>newAdminRoleAcc</ins> gives a <ins>whitelister</ins> the right to
change the white list.
```
await airdrop.grantRole(airdrop.WHITELISTER_ROLE(), whiteLister);
```
 
### Get a list of all <ins>whitelisters</ins>
<ins>newAdminRoleAcc</ins> can iterate all <ins>whitelisters</ins> to
see who was granted this role.
 
```
await airdrop.getRoleMemberCount(airdrop.WHITELISTER_ROLE());
 
await airdrop.getRoleMember(airdrop.WHITELISTER_ROLE(), i));
```
 
### Revoke a role
<ins>newAdminRoleAcc</ins> removes a <ins>whiteLister</ins> its rights to change the white list.
 
```
await airdrop.revokeRole(airdrop.WHITELISTER_ROLE(), whiteLister);
```
 
### Add accounts to the white list
<ins>whiteLister</ins> modifies the white list.
Parameter `addressList` contains the list of accounts to add to the white list. `amountList` has the amounts for each account on `addressList`, matched by their index. `tokenAddress` represents the token for this airdrop.

This function can also be used to modify current data on the whitelist. The last boolean parameter indicates if the previously stored amount (if any) should be overridden. If “true” the new amount simply replaces the stored value. If "false" the stored amount is increased by the new amount.
 
```
await airdrop.addToWhiteList(tokenAddress, addressList[], amountList[], false);
```
 
### Add only one account to the white list
<ins>whiteLister</ins> could also add or modify only one <ins>claimer</ins> on the list. Last parameter indicates if the previous amount should be overridden with the new amount.
 
```
await airdrop.addOnetoWhiteList( tokenAddress, claimer, amount, true);
```
 
### Reduce claimable amount
<ins>whiteLister</ins> reduces the claimable amount for one <ins>claimer</ins>, subtracting `amount` from the previously stored amount.
 
```
await airdrop.subtractFromWhiteList(tokenAddress, claimer, amount);
```
 
### Check amount left for one account
<ins>whiteLister</ins> checks how many claimable tokes a <ins>claimer</ins> can still claim
 
```
await airdrop.getWhiteListedClaimableBalance(tokenAddress, claimer);
```
 
### Claimer checks its balance
<ins>claimer</ins> account checks how many tokes it can claim.
 
```
await airdrop.getMyClaimableBalance(tokenAddress);
```
 
### Claiming tokens
<ins>claimer</ins> claims some or all of its tokens.
 
```
await airdrop.claimMyTokens(tokenOwner, token.address, amount);
```

## Disclaimer

The material embodied in this software is provided to you "as-is" and without warranty of any kind, express, implied or otherwise, including without limitation, any warranty of fitness for a particular purpose. In no event shall Xave Project be liable to you or anyone else for any direct, special, incidental, indirect or consequential damages of any kind, or any damages whatsoever, including without limitation, loss of profit, loss of use, savings or revenue, or the claims of third parties, whether or not Xave Project has been advised of the possibility of such loss, however caused and on any theory of liability, arising out of or in connection with the possession, use or performance of this software.

More on this on https://xavecoin.com/termsconditions/



## License

[![License: LGPL v3](https://img.shields.io/badge/License-LGPL%20v3-blue.svg)](https://www.gnu.org/licenses/lgpl-3.0)

This program is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.