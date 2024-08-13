
#Requires -Version 5.1
#Requires -RunAsAdministrator
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    $script:groupName = 'AddMemberToGroup'
    Install-CLocalGroup -Name $script:groupName -Description "Carbon Install-CLocalGroupMember."

    $script:user1 = $CarbonTestUser
    $script:user2 = $CarbonTestUser2

    function Assert-MembersInGroup
    {
        param(
            [string[]]$Member
        )

        foreach ($_member in $Member)
        {
            Get-LocalGroupMember -Name $script:groupName -Member $_member | Should -Not -BeNullOrEmpty
        }
    }

    function Invoke-AddMembersToGroup($Members = @())
    {
        Install-CLocalGroupMember -Name $script:groupName -Member $Members
        Assert-MembersInGroup -Member $Members
    }

}

AfterAll {
    Remove-LocalGroup -Name $script:groupName
}


Describe 'Install-CLocalGroupMember' {

    BeforeEach {
        $Global:Error.Clear()

        Get-LocalGroupMember -Name $script:groupName |
            ForEach-Object { Remove-LocalGroupMember -Name $script:groupName -Member $_ }
    }

    $skip = (Test-Path -Path 'env:WHS_CI') -and $env:WHS_CI -eq 'True'

    It 'should add member from domain' -Skip:$skip {
        Invoke-AddMembersToGroup -Members 'WBMD\WHS - Lifecycle Services'
    }

    It 'should add local user' {
        $users = Get-LocalUser
        if( -not $users )
        {
            Fail "This computer has no local user accounts."
        }
        $addedAUser = $false
        foreach( $user in $users )
        {
            Invoke-AddMembersToGroup -Members $user.Name
            $addedAUser = $true
            break
        }
        $addedAuser | Should -BeTrue
    }

    It 'should add multiple members' {
        $members = @( $script:user1, $script:user2 )
        Invoke-AddMembersToGroup -Members $members
    }

    It 'should support should process' {
        Install-CLocalGroupMember -Name $script:groupName -Member $script:user1 -WhatIf
        $details = net localgroup $script:groupName
        foreach( $line in $details )
        {
            ($details -like ('*{0}*' -f $script:user1)) | Should -BeFalse
        }
    }

    It 'should add network service' {
        Install-CLocalGroupMember -Name $script:groupName -Member 'NetworkService'
        Test-CLocalGroupMember -Name $script:groupName -Member 'Network Service' | Should -BeTrue
    }

    It 'handles accounts that are already group members' {
        Install-CLocalGroupMember -Name $script:groupName -Member 'NetworkService'
        Install-CLocalGroupMember -Name $script:groupName -Member 'NetworkService'
        $Global:Error | Should -BeNullOrEmpty
    }

    $builtinAccounts = @('Administrators', 'Power Users', 'Remote Desktop Users', 'Users')
    It 'refuses to add builtin local group "<_>" to local group' -ForEach $builtinAccounts {
        Install-CLocalGroupMember -Name $script:groupName -Member $_ -ErrorAction SilentlyContinue
        $Global:Error | Should -Match 'does not support nested local groups'
    }

    It 'should not add non existent member' {
        $numMembersBefore =
            Get-LocalGroupMember -Group $script:groupName | Measure-Object | Select-Object -ExpandProperty 'Count'
        Install-CLocalGroupMember -Name $script:groupName -Member 'FJFDAFJ' -ErrorAction SilentlyContinue
        Get-LocalGroupMember -Group $script:groupName | Measure-Object | Select-Object -ExpandProperty 'Count' |
            Should -Be $numMembersBefore
    }

    $wellKnownAccounts = @('Everyone', 'Authenticated Users', 'ANONYMOUS LOGON', 'Fax', 'NetworkService')
    It 'allows local well known group "<_>"' -ForEach $wellKnownAccounts {
        if (-not (TEst-CIdentity -Name $_))
        {
            return
        }

        Install-CLocalGroupMember -Name $script:groupName -Member $_
        $Global:Error | Should -BeNullOrEmpty
        Test-CLocalGroupMember -Name $script:groupName -Member $_ | Should -BeTrue
    }

    It 'allows duplicates' {
        $admin = Resolve-CIdentity 'Administrator'
        Install-CLocalGroup -Name $script:groupName -Member $admin.Name, $admin.FullName
        $Global:Error | Should -BeNullOrEmpty
    }
}
