<!--markdownlint-disable MD012 no-multiple-blanks-->
<!--markdownlint-disable MD024 no-duplicate-heading-->

# Carbon.Accounts PowerShell Module Changelog

## 1.1.0

### Upgrade Instructions

If migrating from Carbon's group functions (`Add-CGroupMember`, `Get-CGroup`, `Install-CGroup`, `Remove-CGroupMember`,
`Test-CGroup`, `Test-CGroupMember`, and `Uninstall-CGroup`):

* Functions re-written to use PowerShell's built-in `Microsoft.PowerShell.LocalAccounts` module so they do not support
  running under 32-bit PowerShell on a 64-bit operating system.
* Rename usages of `Install-CGroup`, `Add-CGroupMember`, and `Remove-CGroupMember` function's `Members` parameter to
  `Member`.
* Remove usages of `Install-CGroup` function's `PassThru` switch. Use `Get-LocalGroup` instead.
* Rename usages of `Test-CGroupMember` function's `GroupName` parameter to `Name`.
* `Install-CGroup` and `Add-CGroupMember` no longer support adding a local group to a group and writes an error instead.
  Previously, local built-in groups were allowed to be added because the underlying Windows API allowed them, but
  functionally, Windows ignores local groups in a local group. Review usages. To check if a group is a local group, use
  `Resolve-CIdentity` and if the `Type` property on the returned object is `Alias` and the group is not a domain group,
  it will cause an error.
* Rename usages of `Add-CGroupMember` to `Install-CLocalGroupMember`.
* Rename usages of `Get-CGroup` to `Get-CLocalGroup`.
* Rename usages of `Install-CGroup` to `Install-CLocalGroup`.
* Rename usages of `Remove-CGroupMember` to `Uninstall-CLocalGroupMember`.
* Rename usages of `Test-CGroup` to `Test-CLocalGroup`.
* Rename usages of `Test-CGroupMember` to `Test-CLocalGroupMember`.
* Rename usages of `Uninstall-CGroup` to `Uninstall-CLocalGroup`.

### Added

* `Get-CLocalGroup` for getting local groups. Has support for non-wildcard lookups.
* `Install-CLocalGroup` for installing local groups.
* `Install-CLocalGroupMember` for adding accounts to local groups.
* `Test-CLocalGroup` for testing if local groups exist.
* `Test-CLocalGroupMember` for testing if accounts are in a local group.
* `Uninstall-CGroup` for removing groups.
* `Uninstall-CGroupMember` for removing accounts from a group.


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
