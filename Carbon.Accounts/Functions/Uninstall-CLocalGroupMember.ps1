
function Uninstall-CLocalGroupMember
{
    <#
    .SYNOPSIS
    Removes accounts from a local group, if they are part of the group.

    .DESCRIPTION
    The `Uninstall-CLocalGroupMember` function removes accounts from local groups. Pass the group name to the `Name`
    parameter. Pass the account names to the `Member` parameter. If the given accounts are in the local group, they are
    removed. Any account that is not in the group is ignored.

    The function writes an error if the group doesn't exist, or if any of the members you're trying to remove from the
    group don't exist.

    This function uses the Microsoft.PowerShell.LocalAccounts cmdlets, so is not supported on 32-bit PowerShell running
    on a 64-bit operating system.

    .EXAMPLE
    Uninstall-CLocalGroupMember -Name Administrators -Member EMPIRE\DarthVader,EMPIRE\EmperorPalpatine,REBELS\LSkywalker

    Demonstrates how to remove multiple accounts from a group by passing multiple account names to the `Member`
    parameter. In this example, Darth Vader, Emperor Palpatine and Luke Skywalker are removed from the local
    administrators group.

    .EXAMPLE
    Uninstall-CLocalGroupMember -Name TieFighters -Member NetworkService

    Demonstrates how to remove a single account from a group by passing the account name to the `Member` parameter. In
    this example, the local NetworkService account is removed from the local TieFighters group.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The group name.
        [Parameter(Mandatory)]
        [String] $Name,

        # The users/groups to remove from a group.
        [Parameter(Mandatory)]
        [String[]] $Member
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    if (-not (Test-CLocalGroup -LiteralName $Name))
    {
        $msg = "Failed to remove members from local group ""${Name}"" because that group does not exist."
        Write-Error -Message $msg -ErrorAction $ErrorActionPreference
        return
    }

    $groupInfo = Resolve-CIdentity -Name $Name

    $localGroupName = $groupInfo.Name
    $prefix = "Removing member from local group ""$($groupInfo.Name)""  "

    foreach ($_member in $Member)
    {
        if (-not (Test-CLocalGroupMember -Name $localGroupName -Member $_member))
        {
            continue
        }

        Write-Information "${prefix}- ${_member}"
        $prefix = ' ' * $prefix.Length
        Remove-LocalGroupMember -Name $localGroupName -Member $_member
    }
}
