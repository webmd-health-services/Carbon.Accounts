
function Resolve-CIdentity
{
    <#
    .SYNOPSIS
    Gets domain, name, type, and SID information about a user or group.

    .DESCRIPTION
    The `Resolve-CIdentity` function takes an identity name or security identifier (SID) and gets its canonical
    representation. It returns a `Carbon_Accounts_Identity` object, which contains the following information about the
    identity:

     * Domain - the domain the user was found in
     * FullName - the users full name, e.g. Domain\Name
     * Name - the user's username or the group's name
     * Type - the Sid type.
     * Sid - the account's security identifier as a `System.Security.Principal.SecurityIdentifier` object.

    The common name for an account is not always the canonical name used by the operating system.  For example, the
    local Administrators group is actually called BUILTIN\Administrators.  This function uses the `LookupAccountName`
    and `LookupAccountSid` Windows functions to resolve an account name or security identifier into its domain, name,
    full name, SID, and SID type.

    You may pass a `System.Security.Principal.SecurityIdentifer`, a SID in SDDL form (as a string), or a SID in binary
    form (a byte array) as the value to the `SID` parameter. You'll get an error and nothing returned if the SDDL or
    byte array SID are invalid.

    If the name or security identifier doesn't represent an actual user or group, an error is written and nothing is
    returned.

    .LINK
    Test-CIdentity

    .LINK
    Resolve-CIdentityName

    .LINK
    http://msdn.microsoft.com/en-us/library/system.security.principal.securityidentifier.aspx

    .LINK
    http://msdn.microsoft.com/en-us/library/windows/desktop/aa379601.aspx

    .LINK
    ConvertTo-CSecurityIdentifier

    .LINK
    Resolve-CIdentityName

    .LINK
    Test-CIdentity

    .OUTPUTS
    Carbon_Accounts_Identity.

    .EXAMPLE
    Resolve-CIdentity -Name 'Administrators'

    Returns an object representing the `Administrators` group.

    .EXAMPLE
    Resolve-CIdentity -SID 'S-1-5-21-2678556459-1010642102-471947008-1017'

    Demonstrates how to use a SID in SDDL form to convert a SID into an identity.

    .EXAMPLE
    Resolve-CIdentity -SID ([Security.Principal.SecurityIdentifier]::New()'S-1-5-21-2678556459-1010642102-471947008-1017')

    Demonstrates that you can pass a `SecurityIdentifier` object as the value of the SID parameter.

    .EXAMPLE
    Resolve-CIdentity -SID $sidBytes

    Demonstrates that you can use a byte array that represents a SID as the value of the `SID` parameter.
    #>
    [CmdletBinding()]
    param(
        # The name of the identity to return.
        [Parameter(Mandatory, ParameterSetName='ByName', Position=0)]
        [string] $Name,

        # The SID of the identity to return. Accepts a SID in SDDL form as a `string`, a
        # `System.Security.Principal.SecurityIdentifier` object, or a SID in binary form as an array of bytes.
        [Parameter(Mandatory , ParameterSetName='BySid')]
        [Object] $SID
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    if ($PSCmdlet.ParameterSetName -eq 'BySid')
    {
        $SID = ConvertTo-CSecurityIdentifier -SID $SID
        if (-not $SID)
        {
            return
        }

        $sidBytes = [byte[]]::New($SID.BinaryLength)
        $SID.GetBinaryForm($sidBytes, 0)
        $account = Invoke-AdvapiLookupAccountSid -Sid $sidBytes
        if (-not $account)
        {
            Write-Error -Message "SID ""${SID}"" not found." -ErrorAction $ErrorActionPreference
            return
        }
        return [Carbon_Accounts_Identity]::New($account.ReferencedDomainName, $account.Name, $SID, $account.Use)
    }

    if ($Name.StartsWith('.\'))
    {
        $username = $Name.Substring(2)
        $Name = "$([Environment]::MachineName)\${username}"
        $identity = Resolve-CIdentity -Name $Name
        if (-not $identity)
        {
            $Name = "BUILTIN\${username}"
            $identity = Resolve-CIdentity -Name $Name
        }
        return $identity
    }

    if ($Name.Equals("LocalSystem", [StringComparison]::InvariantCultureIgnoreCase))
    {
        $Name = "NT AUTHORITY\SYSTEM"
    }

    $account = Invoke-AdvapiLookupAccountName -AccountName $Name
    if (-not $account)
    {
        Write-Error -Message "Identity ""${Name}"" not found." -ErrorAction $ErrorActionPreference
        return
    }

    $sid = [SecurityIdentifier]::New($account.Sid, 0)
    $ntAccount = $sid.Translate([NTAccount])
    $domainName,$accountName = $ntAccount.Value.Split('\', 2)
    if (-not $accountName)
    {
        $accountName = $domainName
        $domainName = ''
    }
    return [Carbon_Accounts_Identity]::New($domainName, $accountName, $sid, $account.Use)

}