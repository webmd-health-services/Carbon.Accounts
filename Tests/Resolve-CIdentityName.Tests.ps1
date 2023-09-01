
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
}


Describe 'Resolve-CIdentityName' {
    BeforeEach {
        $Global:Error.Clear()
    }

    It 'should resolve builtin identity' {
        $identity = Resolve-CIdentityName -Name 'Administrators'
        $identity | Should -Be 'BUILTIN\Administrators'
    }

    It 'should resolve n t authority identity' {
        $identity = Resolve-CIdentityName -Name 'NetworkService'
        $identity | Should -Be 'NT AUTHORITY\NETWORK SERVICE'
    }

    It 'should resolve everyone' {
        $identity  = Resolve-CIdentityName -Name 'Everyone'
        $identity | Should -Be 'Everyone'
    }

    It 'should not resolve made up name' {
        $fullName = Resolve-CIdentityName -Name 'IDONotExist'
        $Global:Error.Count | Should -Be 0
        $fullName | Should -BeNullOrEmpty
    }

    It 'should resolve local system' {
        (Resolve-CIdentityName -Name 'localsystem') | Should -Be 'NT AUTHORITY\SYSTEM'
    }

    It 'should resolve dot accounts' {
        foreach( $user in (Get-CUser) )
        {
            $id = Resolve-CIdentityName -Name ('.\{0}' -f $user.SamAccountName)
            $id | Should -Be ('{0}\{1}' -f $env:COMPUTERNAME,$user.SamAccountName)
        }
    }

    It 'should resolve by sid' {
        $id = Resolve-CIdentity -Name 'Administrators'
        $id | Should -Not -BeNullOrEmpty
        $id = Resolve-CIdentityName -Sid $id.Sid.ToString()
        $id | Should -Be 'BUILTIN\Administrators'
    }

    It 'should resolve by unknown sid' {
        $id = Resolve-CIdentityName -SID 'S-1-5-21-2678556459-1010642102-471947008-1017'
        'S-1-5-21-2678556459-1010642102-471947008-1017' | Should -Be $id
        $Global:Error.Count | Should -Be 0
    }

}
