
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1')

    $script:groupName = 'Uninstall-CLocalGroup'
    $script:description = 'Used by Uninstall-CLocalGroup.Tests.ps1'
}

Describe 'Uninstall-CLocalGroup' {
    BeforeEach {
        Install-CLocalGroup -Name $script:groupName -Description $script:description
        $Global:Error.Clear()
    }

    AfterEach {
        Uninstall-CLocalGroup -Name $script:groupName
    }

    It 'deletes groups' {
        Test-CLocalGroup -Name $script:groupName | Should -BeTrue
        Uninstall-CLocalGroup -Name $script:groupName
        Test-CLocalGroup -Name $script:groupName | Should -BeFalse
    }

    It 'ignores missing groups' {
        Uninstall-CLocalGroup -Name 'fubarsnafu'
        $Global:Error | Should -BeNullOrEmpty
    }

    It 'supports WhatIf' {
        Uninstall-CLocalGroup -Name $script:groupName -WhatIf
        Test-CLocalGroup -Name $script:groupName | Should -BeTrue
    }

    It 'does not support wildcards' {
        # Make sure the test that the group exists does not use wildcards.
        Uninstall-CLocalGroup -Name "${script:groupName}*"
        Test-CLocalGroup -LiteralName $script:groupName | Should -BeTrue

        # Make sure the command to get the group to delete use wildcards.
        Mock -CommandName 'Test-CLocalGroup' -ModuleName 'Carbon.Accounts' -MockWith { $true }
        Uninstall-CLocalGroup -Name "${script:groupName}*"
        Test-CLocalGroup -LiteralName $script:groupName | Should -BeTrue
    }
}
