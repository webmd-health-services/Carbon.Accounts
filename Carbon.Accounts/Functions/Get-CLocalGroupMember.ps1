
function Get-CLocalGroupMember
{
    <#
    .SYNOPSIS
    Gets the members of a local group.

    .DESCRIPTION
    The `Get-CLocalGroupMember` function gets the members of a local group. Pass the name of the group to the `Name`
    parameter. All the group's members are returned as `Carbon_Accounts_Identity` objects.

    If you want to get a specific group member, pass its name to the `Member` parameter. If the user isn't a member of
    the group, the function writes an error and returns nothing. If you want to check if a principal is a member of a
    group, use the `Test-CLocalGroupMember` function instead.

    .EXAMPLE
    Get-CLocalGroupMember -Name 'Administrators'

    Demonstrates how to get the members of a local group. In this case, all the members of the Administrators group is
    returned.

    .EXAMPLE
    Get-CLocalGroupMember -Name 'Administrators' -Member 'someuser'

    Demonstrates how to get a specific member of a local group. You probably want to use `Test-CLocalGroupMember`
    instead.
    #>
    [CmdletBinding(DefaultParameterSetName='ByWildcardName')]
    param(
        [Parameter(Mandatory, Position=0)]
        [String] $Name,

        [String] $Member
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    $group = Get-CLocalGroup -LiteralName $Name
    if (-not $group)
    {
        return
    }

    $memberToFind = $null
    if ($Member)
    {
        $memberToFind = Resolve-CIdentity -Name $Member
        if (-not $memberToFind)
        {
            return
        }
    }

    $foundMember = $false
    Invoke-NetApiNetLocalGroupGetMembers -LocalGroupName $group.Name -Level 0 |
        ForEach-Object {
            $sid = [Security.Principal.SecurityIdentifier]::New([IntPtr]$_.SidPtr)
            return Resolve-CIdentity -Sid $sid -ErrorAction Ignore
        } |
        Where-Object {
            if ($memberToFind)
            {
                $isMember = $memberToFind.FullName -eq $_.FullName
                if ($isMember)
                {
                    $foundMember = $true
                }
                return $isMember
            }

            return $true
        } |
        Write-Output

    if ($memberToFind -and -not $foundMember)
    {
        $msg = "Principal ""$($memberToFind.FullName)"" is not a member of group ""$($group.Name)""."
        Write-Error -Message $msg -ErrorAction $ErrorActionPreference
    }
}
