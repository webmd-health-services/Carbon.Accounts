
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1')

    $script:groupName = 'Test-CLocalGroupMember'
    $script:description = 'Used by Test-CLocalGroupMember.Tests.ps1'

    Install-CLocalGroup -Name $script:groupName -Description $script:description

    Install-CLocalGroupMember -Name $script:groupName -Member $CarbonTestUser
}

AfterAll {
    Uninstall-CLocalGroup -Name 'Test-CLocalGroupMember'
}

Describe 'Test-CLocalGroupMember' {
    BeforeEach {
        $Global:Error.Clear()
    }

    It 'should find a group member' {
        $result = Test-CLocalGroupMember -Name $script:groupName -Member $CarbonTestUser
        $result | Should -BeTrue
        $Global:Error | Should -BeNullOrEmpty
    }

    It 'should not find a group member' {
        Test-CLocalGroupMember -Name $script:groupName -Member 'Authenticated Users' | Should -BeFalse
        $Global:Error | Should -BeNullOrEmpty
    }

    It 'should not find a non existent user' {
        $result = Test-CLocalGroupMember -Name $script:groupName -Member 'nonExistantUser' -ErrorAction SilentlyContinue
        $result | Should -BeNullOrEmpty
        $Global:Error[0] | Should -Match 'identity.*not found'
    }

    It 'validates group exists' {
        $result = Test-CLocalGroupMember -Name 'oiuewldsanfds' -Member 'Authenticated Users' -ErrorAction SilentlyContinue
        $result | Should -BeNullOrEmpty
        $Global:Error[0] | Should -Match 'does not exist'
    }

    It 'validates member exists' {
        $result = Test-CLocalGroupMember -Name $script:groupName `
                                         -Member 'fjksmlkrwwum' `
                                         -ErrorAction SilentlyContinue
        $result | Should -BeNullOrEmpty
        $Global:Error[0] | Should -Match 'not found'
    }

    It 'supports machine prefixed account name' {
        Install-CLocalGroupMember -Name $script:groupName -Member 'Administrator'
        $identity = Resolve-CIdentity -Name 'Administrator'
        Test-CLocalGroupMember -Name $script:groupName -Member $identity.FullName | Should -BeTrue
        $Global:Error | Should -BeNullOrEmpty
    }
}