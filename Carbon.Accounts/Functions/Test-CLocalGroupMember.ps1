
function Test-CLocalGroupMember
{
    <#
    .SYNOPSIS
    Tests if an account is a member of a local group.

    .DESCRIPTION
    The `Test-CLocalGroupMember` function tests if a user or group is a member of a local group. Pass the group name to
    the `Name` parameter. Pass the account name to the `Member` parameter. The function returns `$true` if the member is
    in the group, `$false` otherwise.

    If the group or member don't exist, the function writes an error and return nothing.

    This function uses the Microsoft.PowerShell.LocalAccounts cmdlets, so is not supported on 32-bit PowerShell running
    on a 64-bit operating system.

    .LINK
    Install-CLocalGroupMember

    .LINK
    Install-CLocalGroup

    .LINK
    Uninstall-CLocalGroupMember

    .LINK
    Test-CLocalGroup

    .LINK
    Uninstall-CLocalGroup

    .EXAMPLE
    Test-CLocalGroupMember -Name 'SithLords' -Member 'REBELS\LSkywalker'

    Demonstrates how to test if a user is a member of a group. In this case, it tests if `REBELS\LSkywalker` is in the
    local `SithLords`, *which obviously he isn't*, so `$false` is returned.
    #>
    [CmdletBinding()]
    param(
        # The name of the group whose membership is being tested.
        [Parameter(Mandatory)]
        [String] $Name,

        # The name of the member to check.
        [Parameter(Mandatory)]
        [String] $Member
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    # PowerShell's local account cmdlets don't accept names with local machine name prefix.
    $groupInfo = Resolve-CIdentity -Name $Name
    if (-not $groupInfo)
    {
        Write-Error -Message "Local group ""${Name}"" does not exist." -ErrorAction $ErrorActionPreference
        return
    }

    $group = Get-LocalGroup -Name $groupInfo.Name
    if (-not $group)
    {
        return
    }

    $principal = Resolve-CIdentity -Name $Member
    if (-not $principal)
    {
        return
    }

    $existingMember =
        Get-LocalGroupMember -Name $groupInfo.Name |
        ForEach-Object { Resolve-CIdentityName -Name $_.Name } |
        Where-Object { $_ -eq $principal.FullName }
    if ($existingMember)
    {
        return $true
    }

    return $false
}
