
function Test-CLocalGroup
{
    <#
    .SYNOPSIS
    Checks if a local group exists.

    .DESCRIPTION
    The `Test-CLocalGroup` function tests if a local group exists. Pass the group name to the `Name` parameter. Returns
    `$true` if the group exists, `$false` otherwise.

    .OUTPUTS
    System.Boolean

    .LINK
    Get-CLocalGroup

    .LINK
    Install-CLocalGroup

    .LINK
    Uninstall-CLocalGroup

    .EXAMPLE
    Test-CLocalGroup -Name 'RebelAlliance'

    Checks if the `RebelAlliance` local group exists.  Returns `$true` if it does, `$false` if it doesn't.
    #>
    [CmdletBinding()]
    param(
        # The name of the *local* group to check.
        [Parameter(Mandatory)]
        [String] $Name
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    $group = Get-LocalGroup -Name $Name -ErrorAction Ignore
    if ($group)
    {
        return $true
    }

    return $false
}

