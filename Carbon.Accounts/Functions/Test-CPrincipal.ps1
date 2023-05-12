
function Test-CPrincipal
{
    <#
    .SYNOPSIS
    Tests that a name is a valid Windows local or domain user/group.

    .DESCRIPTION
    Uses the Windows `LookupAccountName` function to find a principal.  If it can't be found, returns `$false`.
    Otherwise, it returns `$true`.

    Use the `PassThru` switch to return a `Carbon.Identity` object (instead of `$true` if the identity exists.

    .LINK
    Resolve-CPrincipal

    .LINK
    Resolve-CPrincipalName

    .EXAMPLE
    Test-CPrincipal -Name 'Administrators

    Tests that a user or group called `Administrators` exists on the local computer.

    .EXAMPLE
    Test-CPrincipal -Name 'CARBON\Testers'

    Tests that a group called `Testers` exists in the `CARBON` domain.

    .EXAMPLE
    Test-CPrincipal -Name 'Tester' -PassThru

    Tests that a user or group named `Tester` exists and returns a `System.Security.Principal.SecurityIdentifier` object
    if it does.
    #>
    [CmdletBinding()]
    param(
        # The name of the identity to test.
        [Parameter(Mandatory)]
        [string] $Name,

        # Returns a `Carbon.Identity` object if the identity exists.
        [switch] $PassThru
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    $principal = Resolve-CPrincipal -Name $Name -ErrorAction Ignore
    if (-not $principal)
    {
        return $false
    }

    if ($PassThru)
    {
        return $principal
    }
    return $true
}

