
function Uninstall-CLocalGroup
{
    <#
    .SYNOPSIS
    Removes a *local* group.

    .DESCRIPTION
    The `Uninstall-CLocalGroup` function removes a local group. Pass the group name to the `Name` parameter. If the
    group exists, it is removed. Otherwise, if the group doesn't exist, nothing happens.

    .LINK
    Install-CLocalGroupMember

    .LINK
    Install-CLocalGroup

    .LINK
    Uninstall-CLocalGroupMember

    .LINK
    Test-CLocalGroup

    .LINK
    Test-CLocalGroupMember

    .INPUTS
    System.String

    .EXAMPLE
    Uninstall-CLocalGroup -Name 'TestGroup1'

    Demonstrates how to uninstall a group. In this case, the `TestGroup1` group is removed.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        # The name of the group to remove/uninstall.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [String] $Name
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    if( -not (Test-CLocalGroup -Name $Name) )
    {
        return
    }

    Write-Information "Deleting local group ""${Name}""."
    Get-LocalGroup -Name $Name | Remove-LocalGroup
}
