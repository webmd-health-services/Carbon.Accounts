
function Assert-CRunAsElevated
{
    <#
    .SYNOPSIS
    Writes an error if the current process is not running with elevated privileges.

    .DESCRIPTION
    The `Assert-CRunAsElevated` function checks if the current process is running with elevated privileges and if it is,
    returns `$true`, otherwise, writes a non-terminating error and returns `$false`.

    On Windows, attempts to run a script with the `#Requires -RunAsAdministrator` directive to check if the current
    process is running as an administrator.

    On Linux and macOS, runs `id -u` to check if the current user is root. If the `id` command doesn't exist, writes an
    errorr and return `$false`.

    This function is also aliased as `Assert-CRunAsAdministrator` and `Assert-CRunAsRoot`, if you want to user more
    platform-specific names.

    .LINK
    https://github.com/PowerShell/PowerShell/blob/master/src/System.Management.Automation/engine/Utils.cs

    .LINK
    Test-CRunAsElevated

    .EXAMPLE
    Assert-CRunAsElevated

    Demonstrates how to write an error if the current process does not have elevated privileges.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    if (Test-CRunAsElevated)
    {
        return $true
    }

    $elevateInstructions = 'running `sudo pwsh`.'
    if ($IsWindows)
    {
        $elevateInstructions = 'by right-clicking the PowerShell application and choose "Run as administrator".'
    }
    $msg = 'PowerShell is not running with elevated privileges. Start PowerShell with elevated privileges by ' +
           "${elevateInstructions}."
    Write-Error -Message $msg -ErrorAction $ErrorActionPreference
    return $false
}

Set-Alias -Name 'Assert-CRunAsAdministrator' -Value 'Assert-CRunAsElevated'
Set-Alias -Name 'Assert-CRunAsRoot' -Value 'Assert-CRunAsElevated'
