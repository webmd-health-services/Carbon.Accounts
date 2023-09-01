
function ConvertTo-CSecurityIdentifier
{
    <#
    .SYNOPSIS
    Converts a string or byte array security identifier into a `System.Security.Principal.SecurityIdentifier` object.

    .DESCRIPTION
    `ConvertTo-CSecurityIdentifier` converts a SID in SDDL form (as a string), in binary form (as a byte array) into a
    `System.Security.Principal.SecurityIdentifier` object. It also accepts
    `System.Security.Principal.SecurityIdentifier` objects, and returns them back to you.

    If the string or byte array don't represent a SID, an error is written and nothing is returned.

    .LINK
    Resolve-CIdentity

    .LINK
    Resolve-CIdentityName

    .EXAMPLE
    ConvertTo-CSecurityIdentifier -SID 'S-1-5-21-2678556459-1010642102-471947008-1017'

    Demonstrates how to convert a a SID in SDDL into a `System.Security.Principal.SecurityIdentifier` object.

    .EXAMPLE
    ConvertTo-CSecurityIdentifier -SID (New-Object 'Security.Principal.SecurityIdentifier' 'S-1-5-21-2678556459-1010642102-471947008-1017')

    Demonstrates that you can pass a `SecurityIdentifier` object as the value of the SID parameter. The SID you passed
    in will be returned to you unchanged.

    .EXAMPLE
    ConvertTo-CSecurityIdentifier -SID $sidBytes

    Demonstrates that you can use a byte array that represents a SID as the value of the `SID` parameter.
    #>
    [CmdletBinding()]
    param(
        # The SID to convert to a `System.Security.Principal.SecurityIdentifier`. Accepts a SID in SDDL form as a
        # `string`, a `System.Security.Principal.SecurityIdentifier` object, or a SID in binary form as an array of
        # bytes.
        [Parameter(Mandatory)]
        $SID
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    try
    {
        if ( $SID -is [string])
        {
            New-Object 'Security.Principal.SecurityIdentifier' $SID
        }
        elseif ($SID -is [byte[]])
        {
            New-Object 'Security.Principal.SecurityIdentifier' $SID,0
        }
        elseif ($SID -is [Security.Principal.SecurityIdentifier])
        {
            $SID
        }
        else
        {
            $msg = "Invalid SID parameter value [$($SID.GetType().FullName)]${SID}. Only " +
                   '[System.Security.Principal.SecurityIdentifier] objects, SIDs in SDDL form as a [String], or SIDs ' +
                   'in binary form as a byte array are allowed.'
            return
        }
    }
    catch
    {
        $sidDisplayMsg = ''
        if ($SID -is [String])
        {
            $sidDisplayMsg = " ""${SID}"""
        }
        elseif ($SID -is [byte[]])
        {
            $sidDisplayMsg = " [$($SID -join ', ')]"
        }
        $msg = "Exception converting SID${sidDisplayMsg} to a [System.Security.Principal.SecurityIdentifier] " +
               'object. This usually means you passed an invalid SID in SDDL form (as a string) or an invalid SID ' +
               "in binary form (as a byte array): ${_}"
        Write-Error $msg -ErrorAction $ErrorActionPreference
        return
    }
}
