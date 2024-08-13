
function Install-CLocalGroup
{
    <#
    .SYNOPSIS
    Creates a new local group, or updates the settings for an existing group.

    .DESCRIPTION
    `Install-CLocalGroup` creates a local group, or, updates a group that already exists. Pass the group's name to the
    `Name` parameter and the group's description to the `Description` parameter. If the group doesn't exist, it is
    created. If it exists, the description is updated. Pass any group members to the `Member` parameter. Those accounts
    will be added to the group. Existing members will be unaffected.

    This function uses the Microsoft.PowerShell.LocalAccounts cmdlets, so is not supported on 32-bit PowerShell running
    on a 64-bit operating system.

    .EXAMPLE
    Install-CLocalGroup -Name TIEFighters -Description 'Users allowed to be TIE fighter pilots.' -Members EMPIRE\Pilots,EMPIRE\DarthVader

    If the TIE fighters group doesn't exist, it is created with the given description and default members.  If it
    already exists, its description is updated and the given members are added to it.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        # The name of the group.
        [Parameter(Mandatory)]
        [String] $Name,

        # A description of the group.
        [String] $Description = '',

        # Members of the group.
        [String[]] $Member = @()
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    $group = Get-LocalGroup -Name $Name -ErrorAction Ignore

    if (-not $group)
    {
        $descMsg = '.'
        if ($Description)
        {
            $descMsg = ": ${Description}"
            if (-not $descMsg.EndsWith('.'))
            {
                $descMsg = "${descMsg}."
            }
        }

        Write-Information "Creating local group ""${Name}""${descMsg}"
        New-LocalGroup -Name $Name -Description $Description
    }
    else
    {
        if ($Description -and $group.Description -ne $Description)
        {
            $groupName = Resolve-CIdentityName -Name $group.Name
            $msg = "Updating local group ""${groupName}"" description.  ""$($group.Description)"" -> ""${Description}"""
            Write-Information $msg
            $group | Set-LocalGroup -Description $Description
        }
    }

    if ($Member)
    {
        Install-CLocalGroupMember -Name $Name -Member $Member
    }
}
