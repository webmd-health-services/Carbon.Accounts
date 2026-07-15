
function Test-CRunAsElevated
{
    <#
    .SYNOPSIS
    Checks if the current process is running with elevated privileges.

    .DESCRIPTION
    The `Test-CRunAsElevated` function checks if the current process is running with elevated privileges. If running
    elevated, returns `$true`, otherwise returns `$false`. Because elevation always involves starting a new, elevated
    process, the check is cached.

    On Windows, attempts to run a script with the `#Requires -RunAsAdministrator` directive to check if the current
    process is running as an administrator.

    On Linux and macOS, runs `id -u` to check if the current user is root. If the `id` command doesn't exist, writes an
    errorr and return `$false`.

    This function is also aliased as `Test-CRunAsAdministrator` and `Test-CRunAsRoot`, if you want to user more
    platform-specific names.

    .LINK
    https://github.com/PowerShell/PowerShell/blob/master/src/System.Management.Automation/engine/Utils.cs

    .LINK
    Assert-CRunAsElevated

    .EXAMPLE
    Test-CRunAsElevated

    Demonstrates how to check if the current process is running with elevated privileges or not.
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
    )

    Set-StrictMode -Version 'Latest'
    Use-CallerPreference -Cmdlet $PSCmdlet -Session $ExecutionContext.SessionState

    # A process is either running as an administrator or not, so we can cache the check.
    if ($null -eq $script:runningElevated)
    {
        if ($IsWindows)
        {
            $numOtherErrors = $Global:Error.Count
            try
            {
                # Use PowerShell itself to check. On non-Windows the RunAsAdministrator `#Requires` directive [always
                # returns
                # true](https://github.com/PowerShell/PowerShell/blob/master/src/System.Management.Automation/engine/Utils.cs#L1189-L1209),
                # so we'll do something else on Linux.
                & (Join-Path -Path $script:moduleDirPath -ChildPath 'bin\Assert-RunAsAdministrator.ps1' -Resolve)
                $script:runningElevated = $true
            }
            catch
            {
                $script:runningElevated = $false

                $numMyErrors = $Global:Error.Count - $numOtherErrors
                for ($count = 0 ; $count -lt $numMyErrors ; ++$count)
                {
                    $Global:Error.RemoveAt(0)
                }
            }
        }
        else
        {
            $uid = $null
            $idCmd = Get-Command -Name 'id' -CommandType 'Application' -ErrorAction 'Ignore' | Select-Object -First 1
            if ($idCmd)
            {
                $uid = & $idCmd.Path -u
            }
            elseif ((Test-Path -Path 'env:UID'))
            {
                $uid = (Get-Item -Path 'env:UID').Value
            }
            else
            {
                $msg = 'Failed to check if current user is running as administrator because neither the `id` command ' +
                       'nor the UID environment variable exist.'
                Write-Error -Message $msg
            }

            $script:runningElevated = ($uid -eq 0)
        }
    }

    return ($script:runningElevated)
}

Set-Alias -Name 'Test-CRunAsAdministrator' -Value 'Test-CRunAsElevated'
Set-Alias -Name 'Test-CRunAsRoot' -Value 'Test-CRunAsElevated'
