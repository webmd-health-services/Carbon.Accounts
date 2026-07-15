using namespace System.Security.Principal

#Requires -RunAsAdministrator
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

# AppVeyor builds don't run as root on Linux so skip these tests if not elevated on Linux.
$script:isElevated = (-not (Test-Path 'variable:IsWindows')) -or (-not $IsWindows -and (id -u) -eq 0)
if (-not $script:isElevated)
{
    Write-Warning "$($PSCommandPath | Split-Path -Leaf) requires root privileges to run."
}

BeforeAll {
    Set-StrictMode -Version 'Latest'

    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\Carbon.Accounts' -Resolve) -Verbose:$false
}

Describe 'Assert-CRunAsElevated' -Skip:(-not $isElevated) {
    BeforeEach {
        $Global:Error.Clear()
    }

    It 'returns true' {
        Assert-CRunAsElevated | Should -BeTrue
        $Global:Error | Should -BeNullOrEmpty
    }
}
