
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
}

Describe 'Resolve-CPrincipal' {
    BeforeEach {
        $Global:Error.Clear()
    }

    It 'resolves BUILTIN principal' {
        $identity = Resolve-CPrincipal -Name 'Administrators'
        $identity.FullName | Should -Be 'BUILTIN\Administrators'
        $identity.Domain | Should -Be 'BUILTIN'
        $identity.Name | Should -Be 'Administrators'
        $identity.Sid | Should -Not -BeNullOrEmpty
        $identity.Type | Should -Be 'Alias'
    }

    It 'resolves NT AUTHORITY principal' {
        $identity = Resolve-CPrincipal -Name 'NetworkService'
        $identity.FullName | Should -Be 'NT AUTHORITY\NETWORK SERVICE'
        $identity.Domain | Should -Be 'NT AUTHORITY'
        $identity.Name | Should -Be 'NETWORK SERVICE'
        $identity.Sid | Should -Not -BeNullOrEmpty
        $identity.Type | Should -Be 'WellKnownGroup'
    }

    It 'resolves Everyone' {
        $identity  = Resolve-CPrincipal -Name 'Everyone'
        $identity.FullName | Should -Be 'Everyone'
        $identity.Domain | Should -Be ''
        $identity.Name | Should -Be 'Everyone'
        $identity.Sid | Should -Not -BeNullOrEmpty
        $identity.Type | Should -Be 'WellKnownGroup'
    }

    It 'does not resolve made up name' {
        $fullName = Resolve-CPrincipal -Name 'IDONotExist' -ErrorAction SilentlyContinue
        $Global:Error.Count | Should -BeGreaterThan 0
        $Global:Error[0].Exception | Should -BeLike '*not found*'
        $fullName | Should -BeNullOrEmpty
    }

    It 'resolves local system' {
        (Resolve-CPrincipal -Name 'localsystem').FullName | Should -Be 'NT AUTHORITY\SYSTEM'
    }

    It 'resolves dot accounts' -Skip {
        foreach( $user in (Get-User) )
        {
            $id = Resolve-CPrincipal -Name ('.\{0}' -f $user.SamAccountName)
            $Global:Error.Count | Should -Be 0
            $id | Should -BeNullOrEmpty
            $user.ConnectedServer | Should -Be $id.Domain
            $user.SamAccountName | Should -Be $id.Name
        }
    }

    It 'resolves sid' {
        @( 'NT AUTHORITY\SYSTEM', 'Everyone', 'BUILTIN\Administrators' ) | ForEach-Object {
            $id = Resolve-CPrincipal -Name $_
            $idFromSid = Resolve-CPrincipal -Sid $id.Sid
            $idFromSid | Should -Be $id
        }
    }

    It 'resolves unknown sid' {
        $id = Resolve-CPrincipal -SID 'S-1-5-21-2678556459-1010642102-471947008-1017' -ErrorAction SilentlyContinue
        $Global:Error.Count | Should -BeGreaterThan 0
        $Global:Error[0] | Should -Match 'not found'
        $id | Should -BeNullOrEmpty
    }

    It 'resolves sid by byte array' {
        $id = Resolve-CPrincipal -Name 'Administrators'
        $id | Should -Not -BeNullOrEmpty
        $sidBytes = New-Object 'byte[]' $id.Sid.BinaryLength
        $id.Sid.GetBinaryForm( $sidBytes, 0 )

        $idBySid = Resolve-CPrincipal -SID $sidBytes
        $idBySid | Should -Not -BeNullOrEmpty
        $Global:Error | Should -HaveCount 0
        $idBySid | Should -Be $id
    }

    It 'handles invalid sddl' {
        $id = Resolve-CPrincipal -SID 'iamnotasid' -ErrorAction SilentlyContinue
        $Global:Error.Count | Should -BeGreaterThan 0
        $Global:Error.Count | Should -BeGreaterThan 0
        $id | Should -BeNullOrEmpty
    }


    It 'handles invalid binary sid' {
        $id = Resolve-CPrincipal -SID (New-Object 'byte[]' 28) -ErrorAction SilentlyContinue
        $Global:Error.Count | Should -BeGreaterThan 0
        $Global:Error.Count | Should -BeGreaterThan 0
        $id | Should -BeNullOrEmpty
    }
}
