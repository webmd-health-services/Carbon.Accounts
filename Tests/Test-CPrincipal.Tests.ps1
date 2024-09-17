
using module '..\Carbon.Accounts'

#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    $script:username = $CarbonTestUser

    function ThenError
    {
        param(
            [switch] $IsEmpty
        )

        $Global:Error | Should -HaveCount 0
    }
}

Describe 'Test-CPrincipal' {
    BeforeEach {
        $Global:Error.Clear()
    }

    It 'finds local group' {
        (Test-CPrincipal -Name 'Administrators') | Should -BeTrue
        ThenError -IsEmpty
    }

    It 'finds local user' {
        (Test-CPrincipal -Name $script:username) | Should -BeTrue
        ThenError -IsEmpty
    }

    $skip = -not [Environment]::UserDomainName -or [Environment]::UserDomainName -eq 'WORKGROUP'
    It 'finds domain user' -Skip:$skip {
        (Test-CPrincipal -Name ('{0}\Administrator' -f $env:USERDOMAIN)) | Should -BeTrue
        ThenError -IsEmpty
    }

    It 'returns security identifier' {
        $sid = Test-CPrincipal -Name $script:username -PassThru
        $sid | Should -Not -BeNullOrEmpty
        ($sid -is [Carbon_Accounts_Principal]) | Should -BeTrue
        ThenError -IsEmpty
    }

    It 'does not find missing local user' {
        (Test-CPrincipal -Name 'IDoNotExistIHope') | Should -BeFalse
        ThenError -IsEmpty
    }

    It 'does not find missing local user with computer for domain' {
        (Test-CPrincipal -Name ('{0}\IDoNotExistIHope' -f $env:COMPUTERNAME)) | Should -BeFalse
        ThenError -IsEmpty
    }

    It 'does not find user in bad domain' {
        (Test-CPrincipal -Name 'MISSINGDOMAIN\IDoNotExistIHope' -ErrorAction SilentlyContinue) | Should -BeFalse
        ThenError -IsEmpty
    }

    It 'does not find user in current domain' {
        (Test-CPrincipal -Name ('{0}\IDoNotExistIHope' -f $env:USERDOMAIN) -ErrorAction SilentlyContinue) | Should -BeFalse
        ThenError -IsEmpty
    }

    It 'finds user with dot domain' {
        $users = Get-CUser
        $users | Should -Not -BeNullOrEmpty
        try
        {
            $foundAUser = $false
            foreach( $user in $users )
            {
                (Test-CPrincipal -Name ('.\{0}' -f $user.SamAccountName)) | Should -BeTrue
                $foundAUser = $true
            }
            $foundAUser | Should -BeTrue
        }
        finally
        {
            $users | ForEach-Object { $_.Dispose() }
        }
        ThenError -IsEmpty
    }

    It 'finds local system' {
        (Test-CPrincipal -Name 'LocalSystem') | Should -BeTrue
        ThenError -IsEmpty
    }
}
