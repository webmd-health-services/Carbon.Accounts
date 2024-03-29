
function Resolve-CIdentityName
{
    <#
    .SYNOPSIS
    Determines the full, NT identity name for a user or group.

    .DESCRIPTION
    `Resolve-CIdentityName` resolves a user/group name into its full, canonical name, used by the operating system. For
    example, the local Administrators group is actually called BUILTIN\Administrators. With a canonical username, you
    can unambiguously compare identities on objects that contain user/group information.

    If unable to resolve a name into an identity, `Resolve-CIdentityName` returns nothing.

    If you want to get full identity information (domain, type, sid, etc.), use `Resolve-CIdentity`.

    You can also resolve a SID into its identity name. The `SID` parameter accepts a SID in SDDL form as a `[String]`, a
    `[System.Security.Principal.SecurityIdentifier]` object, or a SID in binary form as an array of bytes. If the SID no
    longer maps to an active account, you'll get the original SID in SDDL form (as a string) returned to you.

    .LINK
    ConvertTo-CSecurityIdentifier

    .LINK
    Resolve-CIdentity

    .LINK
    Test-CIdentity

    .LINK
    http://msdn.microsoft.com/en-us/library/system.security.principal.securityidentifier.aspx

    .LINK
    http://msdn.microsoft.com/en-us/library/windows/desktop/aa379601.aspx

    .OUTPUTS
    string

    .EXAMPLE
    Resolve-CIdentityName -Name 'Administrators'

    Returns `BUILTIN\Administrators`, the canonical name for the local Administrators group.
    #>
    [CmdletBinding(DefaultParameterSetName='ByName')]
    [OutputType([String])]
    param(
        # The name of the identity to return.
        [Parameter(Mandatory, ParameterSetName='ByName', Position=0)]
        [String] $Name,

        # Get an identity's name from its SID. Accepts a SID in SDDL form as a `string`, a
        # `System.Security.Principal.SecurityIdentifier` object, or a SID in binary form as an array of bytes.
        [Parameter(Mandatory, ParameterSetName='BySid')]
        [Object] $SID
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    if ($PSCmdlet.ParameterSetName -eq 'ByName')
    {
        return Resolve-CIdentity -Name $Name -ErrorAction Ignore | Select-Object -ExpandProperty 'FullName'
    }

    $id = Resolve-CIdentity -Sid $SID -ErrorAction Ignore
    if ($id)
    {
        return $id.FullName
    }

    return $SID.ToString()
}

