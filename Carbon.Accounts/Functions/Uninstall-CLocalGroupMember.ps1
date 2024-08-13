
function Uninstall-CLocalGroupMember
{
    <#
    .SYNOPSIS
    Removes accounts from a local group, if they are part of the group.

    .DESCRIPTION
    You would think it's pretty easy and straight-forward to remove users/groups from a local group, but you would be wrong.  The quick solution is to use `net localgroup`, but that won't accept user/group names longer than 24 characters.  This means you have to use the .NET Directory Services APIs.  How do you reliably remove both users *and* groups?  What if those users are in a domain?  What if they're in another domain?  What about built-in users?  Fortunately, your brain hasn't exploded.

    So, this function removes users or groups from a *local* group.

    If the user or group is not a member, nothing happens.

    `Uninstall-CLocalGroupMember` is new in Carbon 2.0.

    .EXAMPLE
    Uninstall-CLocalGroupMember -Name Administrators -Member EMPIRE\DarthVader,EMPIRE\EmperorPalpatine,REBELS\LSkywalker

    Removes Darth Vader, Emperor Palpatine and Luke Skywalker from the local administrators group.

    .EXAMPLE
    Uninstall-CLocalGroupMember -Name TieFighters -Member NetworkService

    Removes the local NetworkService account from the local TieFighters group.
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

    if (-not (Test-CLocalGroup -Name $Name))
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
