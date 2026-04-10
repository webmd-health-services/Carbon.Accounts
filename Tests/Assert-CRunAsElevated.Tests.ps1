using namespace System.Security.Principal

#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeDiscovery {
    # Unix defaults to reporting that you're running as administrator.
    $script:isInAdminRole = $true
    if (-not (Test-Path -Path 'variable:IsWindows') -or $IsWindows)
    {
        $identity = [WindowsIdentity]::GetCurrent()
        $principal = [WindowsPrincipal]::new($identity)
        $script:isInAdminRole = $principal.IsInRole([WindowsBuiltInRole]::Administrator)
    }
    else
    {
        $script:isInAdminRole = (id -u) -eq 0
    }
}

BeforeAll {
    Set-StrictMode -Version 'Latest'

    Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath '..\Carbon.Accounts' -Resolve) -Verbose:$false

}

Describe 'Assert-CRunAsElevated' {
    BeforeEach {
        $Global:Error.Clear()
    }

    Context 'running as administrator' -Skip:(-not $script:isInAdminRole) {
        It 'returns true' {
            Assert-CRunAsElevated | Should -BeTrue
            $Global:Error | Should -BeNullOrEmpty
        }
    }

    Context 'not running as administrator' -Skip:$script:isInAdminRole {
        It 'returns false' {
            Assert-CRunAsElevated -ErrorAction SilentlyContinue | Should -BeFalse
            $Global:Error | Should -HaveCount 1
            $Global:Error | Should -Match 'PowerShell is not running with elevated privileges'
        }

        It 'can write a terminating error' {
            { Assert-CRunAsElevated -ErrorAction Stop } |
                Should -Throw '*PowerShell is not running with elevated privileges*'
            $Global:Error | Should -HaveCount 1
        }

        It 'can ignore the error' {
            Assert-CRunAsElevated -ErrorAction Ignore | Should -BeFalse
            $Global:Error | Should -BeNullOrEmpty
        }
    }
}
