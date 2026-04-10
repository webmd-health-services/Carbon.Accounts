using namespace System.Security.Principal

#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeDiscovery {
    # Unix defaults to reporting that you're running as administrator.
    $script:isInAdminRole = $true
    if (-not (Test-Path -Path 'variable:IsWindows') -or $IsWindows)
    {
        $script:IsWindows = $true
        $script:IsLinux = $script:IsMacOS = $false
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

Describe 'Test-CRunAsElevated' {
    BeforeEach {
        # Make sure we aren't using a cached result.
        InModuleScope 'Carbon.Accounts' {
            $script:runningElevated = $null
        }
        $Global:Error.Clear()
    }

    Context 'current user' {
        Context 'running as administrator' -Skip:(-not $script:isInAdminRole) {
            It 'returns true' {
                Test-CRunAsElevated | Should -BeTrue
                $Global:Error | Should -BeNullOrEmpty
            }
        }
        Context 'not running as administrator' -Skip:$script:isInAdminRole {
            It 'returns false' {
                Test-CRunAsElevated | Should -BeFalse
                $Global:Error | Should -BeNullOrEmpty
            }
        }
    }

    Context 'id command not available' -Skip:($IsWindows) {
        BeforeEach {
            Mock 'Get-Command' -ModuleName 'Carbon.Accounts' -MockWith { }
        }

        Context 'UID env var is 0' {
            It 'returns true' {
                Mock 'Test-Path' `
                        -ModuleName 'Carbon.Accounts' `
                        -ParameterFilter { $Path -eq 'env:UID' } `
                        -MockWith { $true }
                Mock 'Get-Item' `
                        -ModuleName 'Carbon.Accounts' `
                        -ParameterFilter { $Path -eq 'env:UID' } `
                        -MockWith { [pscustomobject]@{ Value = '0' } }
                Test-CRunAsElevated | Should -BeTrue
                $Global:Error | Should -BeNullOrEmpty
            }
        }

        Context 'UID env var is not 0' {
            It 'returns false' {
                Mock 'Test-Path' `
                        -ModuleName 'Carbon.Accounts' `
                        -ParameterFilter { $Path -eq 'env:UID' } `
                        -MockWith { $true }
                Mock 'Get-Item' `
                        -ModuleName 'Carbon.Accounts' `
                        -ParameterFilter { $Path -eq 'env:UID' } `
                        -MockWith { [pscustomobject]@{ Value = '101' } }
                Test-CRunAsElevated | Should -BeFalse
                $Global:Error | Should -BeNullOrEmpty
            }
        }

        Context 'UID env var does not exist' {
            It 'fails' {
                Mock 'Test-Path' `
                     -ModuleName 'Carbon.Accounts' `
                     -ParameterFilter { $Path -eq 'env:UID' } `
                     -MockWith { $false }
                Test-CRunAsElevated -ErrorAction SilentlyContinue | Should -BeFalse
                $Global:Error | Should -Match 'failed to check'
            }
        }
    }
}
