
# Carbon.Accounts PowerShell Module Changelog

## 1.0.0

### Upgrade Instructions

If switching to Carbon.Accounts from Carbon, do the following:

* Remove usages of the `ConnectedServer` property on `System.DirectoryServices.AccountManagement.Principal` objects.
That was an extended type property added by Carbon and it no longer exists.
* Remove usages of the `Carbon.Identity` and `Carbon.IdentityType` types. `Carbon.Accounts` now uses and returns native
PowerShell classes and enums instead. The new native/classes enums are identical to the old compiled types, so no need
to update object usages.

### Added

* `ConvertTo-CSecurityIdentifier` (from Carbon).
* `Resolve-CIdentity` (from Carbon).
* `Test-CIdentity` (from Carbon).
* `Resolve-CIdentityName` (from Carbon).
