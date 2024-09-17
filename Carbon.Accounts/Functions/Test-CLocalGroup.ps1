
function Test-CLocalGroup
{
    <#
    .SYNOPSIS
    Checks if a local group exists.

    .DESCRIPTION
    The `Test-CLocalGroup` function tests if a local group exists. Pass the group name to the `Name` parameter. Returns
    `$true` if the group exists, `$false` otherwise.

    Wildcards are supported by the `Name` parameter. If you want to make sure a single group exists using an exact name,
    use the `LiteralName` parameter.

    This function uses the `Microsoft.PowerShell.LocalAccounts` PowerShell module, so is not supported on 32-bit
    PowerShell running on a 64-bit operating system.

    .OUTPUTS
    System.Boolean

    .LINK
    Get-CLocalGroup

    .LINK
    Install-CLocalGroup

    .LINK
    Uninstall-CLocalGroup

    .EXAMPLE
    Test-CLocalGroup -Name 'RebelAlliance'

    Checks if the `RebelAlliance` local group exists.  Returns `$true` if it does, `$false` if it doesn't.

    .EXAMPLE
    Test-CLocalGroup -LiteralName $groupName

    Demonstrates how to check that a single group exists by using the `LiteralName` parameter.
    #>
    [CmdletBinding()]
    param(
        # The name of the local group to check. Wildcards supported.
        [Parameter(Mandatory, ParameterSetName='ByWildcardPattern')]
        [String] $Name,

        # The exact name of the local group to check. Wildcards **not** supported.
        [Parameter(Mandatory, ParameterSetName='ByLiteralName`')]
        [String] $LiteralName
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    $nameArg = @{}
    if ($Name)
    {
        $nameArg['Name'] = $Name
    }

    if ($LiteralName)
    {
        $nameArg['LiteralName'] = $LiteralName
    }

    $group = Get-CLocalGroup @nameArg -ErrorAction Ignore
    if ($group)
    {
        return $true
    }

    return $false
}

