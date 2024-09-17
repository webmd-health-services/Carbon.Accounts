
function Install-CLocalGroupMember
{
    <#
    .SYNOPSIS
    Adds users or groups to a local group, if they aren't already in the group.

    .DESCRIPTION
    The `Install-CLocalGroupMember` adds an account to a local group. If the account is already in the group, nothing
    happens. Pass the name of the group to the `Name` parameter. Pass one or more account names to the `Member`
    parameter.

    If the local group doesn't exist, the function writes an error and does no work. If any of the accounts being added
    to the group don't exist, an error is written for each. Accounts that exist are still added to the group.

    Windows does not support local nested groups. If the account to add to the group is a local group, the function will
    write an error and not add the account to the group.

    This function uses the Microsoft.PowerShell.LocalAccounts cmdlets, so is not supported on 32-bit PowerShell running
    on a 64-bit operating system.

    .EXAMPLE
    Install-CLocalGroupMember -Name Administrators -Member EMPIRE\DarthVader,EMPIRE\EmperorPalpatine,REBELS\LSkywalker

    Adds Darth Vader, Emperor Palpatine and Luke Skywalker to the local administrators group.

    .EXAMPLE
    Install-CLocalGroupMember -Name TieFighters -Member NetworkService

    Adds the local NetworkService account to the local TieFighters group.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The group name.
        [Parameter(Mandatory)]
        [String] $Name,

        # The users/groups to add to a group.
        [Parameter(Mandatory)]
        [String[]] $Member
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    if (-not (Test-CLocalGroup -LiteralName $Name))
    {
        $msg = "Failed to add member to local group ""${Name}"" because local group ""${Name}"" does not exist."
        Write-Error -Message $msg -ErrorAction $ErrorActionPreference
        return
    }

    $groupInfo = Resolve-CIdentity -Name $Name
    $localGroupName = $groupInfo.Name
    $groupName = $groupInfo.FullName

    $prefix = "Adding member to local group ""${localGroupName}""  "

    foreach( $_member in $Member )
    {
        $identity = Resolve-CIdentity -Name $_member
        if (-not $identity)
        {
            continue
        }

        $memberName = $identity.FullName

        if (Test-CLocalGroup -LiteralName $identity.Name)
        {
            $msg = "Failed to add local group ""${memberName}"" to local group ""${groupName}"" because " +
                   """${memberName}"" is a local group and Windows does not support nested local groups."
            Write-Error -Message $msg -ErrorAction $ErrorActionPreference
            continue
        }

        if ((Test-CLocalGroupMember -Name $groupName -Member $_member))
        {
            continue
        }

        if (-not $PSCmdlet.ShouldProcess("local group ${groupName}", "add member ${memberName}"))
        {
            continue
        }

        Write-Information "${prefix}+ ${memberName}"
        $prefix = ' ' * $prefix.Length
        Add-LocalGroupMember -Name $Name -Member $identity.FullName
    }
}
