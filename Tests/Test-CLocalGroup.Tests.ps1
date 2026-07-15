
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeDiscovery {
    if (-not (Test-Path -Path 'variable:IsWindows'))
    {
        $script:IsWindows = $true
        $script:IsLinux = $script:IsMacOS = $false
    }
}

BeforeAll {
    Set-StrictMode -Version 'Latest'
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
}

Describe 'Test-CLocalGroup' {
    BeforeEach {
        $Global:Error.Clear()
    }

    Context 'Windows' -Skip:(-not $IsWindows) {
        It 'finds local groups' {
            $groups = Get-LocalGroup
            $groups | Should -Not -BeNullOrEmpty
            $groups | ForEach-Object { Test-CLocalGroup -Name $_.Name } | Should -BeTrue
            $Global:Error | Should -BeNullOrEmpty
        }

        It 'handles non-existent group' {
            Test-CLocalGroup -Name 'jfnrqnwuiocnja' | Should -BeFalse
            $Global:Error | Should -BeNullOrEmpty
        }

        It 'allows wildcards' {
            Test-CLocalGroup -Name 'Admin*' | Should -BeTrue
            $Global:Error | Should -BeNullOrEmpty
        }

        It 'ignores wildcards' {
            Test-CLocalGroup -LiteralName 'Admin*' | Should -BeFalse
            $Global:Error | Should -BeNullOrEmpty
        }

        It 'finds using exact name' {
            Test-CLocalGroup -LiteralName 'Administrators' | Should -BeTrue
            $Global:Error | Should -BeNullOrEmpty
        }
    }

    Context 'Linux and macOS' -Skip:$IsWindows {
        It 'fails' {
            Test-CLocalGroup -Name 'ignored' -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
            $Global:Error | Should -Match 'only supported on Windows'
        }
    }
}
