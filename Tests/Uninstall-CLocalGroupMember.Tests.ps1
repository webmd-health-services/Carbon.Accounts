
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    function GivenGroup
    {
        param(
            $Name,
            $WithMember
        )

        Uninstall-CLocalGroup -Name $Name
        Install-CLocalGroup -Name $Name -Description 'Carbon.Accounts test group.' -Member $WithMember
    }

    function ThenError
    {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidAssignmentToAutomaticVariable', '')]
        param(
            $Matches
        )

        $Global:Error | Should -Match $Matches
    }

    function ThenNoError
    {
        param(
        )

        $Global:Error | Should -BeNullOrEmpty
    }

    function ThenGroup
    {
        param(
            $Name,

            [String[]] $HasMember
        )

        $group = Get-LocalGroup -Name $Name
        $group | Should -Not -BeNullOrEmpty

        $members = Get-LocalGroupMember -Name $Name
        $members | Should -HaveCount $HasMember.Length

        foreach ($member in $HasMember)
        {
            Test-CLocalGroupMember -Name $Name -Member $member | Should -BeTrue
        }
    }

    function WhenRemoving
    {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]
        [CmdletBinding(SupportsShouldProcess)]
        param(
            $Member,
            $FromGroup
        )

        $Global:Error.Clear()
        Uninstall-CLocalGroupMember -Name $FromGroup -Member $Member
    }
}

Describe 'Uninstall-CLocalGroupMember' {
    It 'removes single member' {
        GivenGroup 'FubarSnafu' -WithMember 'Everyone','Authenticated Users'
        WhenRemoving 'Everyone' -FromGroup 'FubarSnafu'
        ThenGroup 'FubarSnafu' -HasMember 'Authenticated Users'
    }

    It 'removes multiple members' {
        GivenGroup 'FubarSnafu' -WithMember 'Everyone','Authenticated Users','Administrator'
        WhenRemoving 'Everyone','Authenticated Users' -FromGroup 'FubarSnafu'
        ThenGroup 'FubarSnafu' -HasMember 'Administrator'
    }

    It 'removes all members' {
        GivenGroup 'FubarSnafu' -WithMember 'Everyone','Authenticated Users','Administrator'
        WhenRemoving 'Everyone','Authenticated Users','Administrator' -FromGroup 'FubarSnafu'
        ThenGroup 'FubarSnafu' -HasMember @()
    }

    It 'removes user not in group' {
        GivenGroup 'FubarSnafu' -WithMember 'Everyone'
        WhenRemoving 'Authenticated Users' -FromGroup 'FubarSnafu'
        ThenGroup 'FubarSnafu' -HasMember 'Everyone'
        ThenNoError
    }

    It 'removes user that does not exist' {
        GivenGroup 'FubarSnafu' -WithMember 'Everyone'
        WhenRemoving 'fdfsadfdsf' -FromGroup 'FubarSnafu' -ErrorAction SilentlyContinue
        ThenGroup 'FubarSnafu' -HasMember 'Everyone'
        $Global:Error[0] | Should -Match 'not found'
    }

    It 'validates group exists' {
        WhenRemoving 'fdfsadfdsf' -FromGroup 'jkfdsjfldsf' -ErrorAction SilentlyContinue
        $Global:Error[0] | Should -Match 'does not exist'
    }

    It 'supports WhatIf' {
        GivenGroup 'FubarSnafu' -WithMember 'Everyone'
        WhenRemoving 'Everyone' -FromGroup 'FubarSnafu' -WhatIf
        ThenNoError
        ThenGroup 'FubarSnafu' -HasMember 'Everyone'
    }

    It 'does not support wildcards for group name' {
        GivenGroup 'FubarSnafu' -WithMember 'Everyone'
        WhenRemoving 'Everyone' -FromGroup 'FubarSnafu*' -ErrorAction SilentlyContinue
        ThenGroup 'FubarSnafu' -HasMember 'Everyone'
        ThenError -Matches 'does not exist'
    }
}