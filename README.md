<!--markdownlint-disable MD012 no-multiple-blanks-->

# Carbon.Accounts PowerShell Module Overview

The "Carbon.Accounts" module has functions for managing groups, checking if accounts exist, getting canonical account
metadata/information, working with SIDs (security identifiers), and checking for admin/root privileges.


## System Requirements

* Most functions are Windows-only.
* Windows PowerShell 5.1 and .NET 4.6.1+
* PowerShell 7+

Note that local group functions are not supported on 32-bit PowerShell on a 64-bit operating system.


## Installing

To install globally:

```powershell
Install-Module -Name 'Carbon.Accounts'
Import-Module -Name 'Carbon.Accounts'
```

To install privately:

```powershell
Save-Module -Name 'Carbon.Accounts' -Path '.'
Import-Module -Name '.\Carbon.Accounts'
```


## Commands

* `Assert-CRunAsElevated`: writes an error if the current process isn't running with elevated privileges. On Windows,
  validates running as administrator. On Linux and macOS, validates running as root. Also aliased as
  `Assert-CRunAsAdministrator` and `Assert-CRunAsRoot`.
* `ConvertTo-CSecurityIdentifier`: converts a string or byte array security identifier into a
  `System.Security.Principal.SecurityIdentifier` object.
* `Get-CLocalGroup`: gets local groups.
* `Install-CLocalGroup`: creates a new local group, or updates the settings for an existing group.
* `Install-CLocalGroupMember`: adds a users or groups to a local group.
* `Resolve-CPrincipal`: gets domain, name, type, and SID information about a user or group.
* `Resolve-CPrincipalName`: determines the full, NT principal name for a user or group.
* `Test-CRunAsElevated`: checks if the current process is running with elevated privileges. On Windows, checks if
  running as administrator. On Linux and macOS, checks if running as root. Also aliased as `Test-CRunAsAdministrator`
  and `Test-CRunAsRoot`.
* `Test-CPrincipal`: Tests that a name is a valid Windows local or domain user/group.
* `Test-CLocalGroup`: checks if a local group exists.
* `Test-CLocalGroupMember`: tests if an account is a member of a local group.
* `Uninstall-CLocalGroup`: deletes a *local* group if it exists.
* `Uninstall-CLocalGroupMember`: removes accounts from a local group if those accounts are in the group.
