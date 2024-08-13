
function Get-CLocalGroup
{
    <#
    .SYNOPSIS
    Gets local groups.

    .DESCRIPTION
    The `Get-CLocalGroup` gets local groups. By default, it returns all local groups. To return a specific group, use
    the `Name` parameter. Wildcards supported. To get a group without using wildcard searching, use the `LiteralName`
    parameter.

    This function uses the Microsoft.PowerShell.LocalAccounts cmdlets, so is not supported on 32-bit PowerShell running
    on a 64-bit operating system.

    .EXAMPLE
    Get-CLocalGroup

    Demonstrates how to get all local groups.

    .EXAMPLE
    Get-CLocalGroup -Name 'p_*'

    Demonstrates how to get all groups that match a wildcard pattern.

    .EXAMPLE
    Get-CLocalGroup -LiteralName $name

    Demonstrates how to get a single group without doing a wildcard search by using the `LiteralName` parameter.
    #>
    [CmdletBinding(DefaultParameterSetName='All')]
    param(
        # The name of the group to get. Wildcards supported. By default, all groups are returned.
        [Parameter(Mandatory, ParameterSetName='ByWildcardPattern')]
        [String] $Name,

        # The exact name of the single group to get. Wildcards **not** supported. By default, all groups are returned.
        [Parameter(Mandatory, ParameterSetName='ByLiteralName')]
        [String] $LiteralName
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    if (-not $Name -and -not $LiteralName)
    {
        return Get-LocalGroup
    }

    if ($Name)
    {
        return Get-LocalGroup -Name $Name -ErrorAction $ErrorActionPreference
    }

    return Get-LocalGroup | Where-Object 'Name' -EQ $LiteralName
}