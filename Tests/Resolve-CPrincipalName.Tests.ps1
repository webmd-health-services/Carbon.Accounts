
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
}


Describe 'Resolve-CPrincipalName' {
    BeforeEach {
        $Global:Error.Clear()
    }

    It 'should resolve builtin principal' {
        $principal = Resolve-CPrincipalName -Name 'Administrators'
        $principal | Should -Be 'BUILTIN\Administrators'
    }

    It 'should resolve n t authority principal' {
        $principal = Resolve-CPrincipalName -Name 'NetworkService'
        $principal | Should -Be 'NT AUTHORITY\NETWORK SERVICE'
    }

    It 'should resolve everyone' {
        $principal  = Resolve-CPrincipalName -Name 'Everyone'
        $principal | Should -Be 'Everyone'
    }

    It 'should not resolve made up name' {
        $fullName = Resolve-CPrincipalName -Name 'IDONotExist'
        $Global:Error.Count | Should -Be 0
        $fullName | Should -BeNullOrEmpty
    }

    It 'should resolve local system' {
        (Resolve-CPrincipalName -Name 'localsystem') | Should -Be 'NT AUTHORITY\SYSTEM'
    }

    It 'should resolve dot accounts' {
        foreach( $user in (Get-CUser) )
        {
            $id = Resolve-CPrincipalName -Name ('.\{0}' -f $user.SamAccountName)
            $id | Should -Be ('{0}\{1}' -f $env:COMPUTERNAME,$user.SamAccountName)
        }
    }

    It 'should resolve by sid' {
        $id = Resolve-CPrincipal -Name 'Administrators'
        $id | Should -Not -BeNullOrEmpty
        $id = Resolve-CPrincipalName -Sid $id.Sid.ToString()
        $id | Should -Be 'BUILTIN\Administrators'
    }

    It 'should resolve by unknown sid' {
        $id = Resolve-CPrincipalName -SID 'S-1-5-21-2678556459-1010642102-471947008-1017'
        'S-1-5-21-2678556459-1010642102-471947008-1017' | Should -Be $id
        $Global:Error.Count | Should -Be 0
    }

}
