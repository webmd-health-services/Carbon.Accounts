
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

    if (-not $IsWindows)
    {
        return
    }

    if (Get-Command -Name 'Get-LocalGroupMember' -ErrorAction Ignore)
    {
        $script:admins = Get-LocalGroupMember -Name 'Administrators'
    }
}

Describe 'Get-CLocalGroupMember' {

    BeforeEach {
        $Global:Error.Clear()
    }

    Context 'Windows' -Skip:(-not $IsWindows) {
        It 'gets group members' {
            $actualMembers = Get-CLocalGroupMember -Name 'Administrators'
            $actualMembers | Should -HaveCount $script:admins.Count
        }

        It 'gets specific member' {
            $expectedMember = $script:admins | Select-Object -First 1
            $expectedMember |
                Should -Not -BeNullOrEmpty -Because 'There must be at least one member in the Administrators group.'
            $actualMember = Get-CLocalGroupMember -Name 'Administrators' -Member $expectedMember.Name
            $actualMember | Should -Not -BeNullOrEmpty
            $actualMember.FullName | Should -Be $expectedMember.Name
        }

        It 'does not find specific member' {
            $member = Get-CLocalGroupMember -Name 'Administrators' -Member 'CarbonTestUser2' -ErrorAction SilentlyContinue
            $member | Should -BeNullOrEmpty
            $Global:Error | Should -Match 'is not a member'
        }

        It 'validates member' {
            $members = Get-CLocalGroupMember -Name 'Administrators' -Member 'SnafuFubar' -ErrorAction SilentlyContinue
            $members | Should -BeNullOrEmpty
            $Global:Error[0] | Should -Match 'Principal.*not found'
        }
    }

    Context 'Linux and macOS' -Skip:$IsWindows {
        It 'fails' {
            $result = Get-CLocalGroupMember -Name 'does not matter' -ErrorAction SilentlyContinue
            $result | Should -BeNullOrEmpty
            $Global:Error | Should -Match 'only supported on Windows'
        }
    }
}