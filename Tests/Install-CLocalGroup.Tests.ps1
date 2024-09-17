
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'

    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)

    $script:testNum = 0
    $script:groupName = 'Install-CLocalGroup'
    $script:userName = $CarbonTestUser
    $script:description = 'Carbon group for use in Carbon tests.'

    function ThenGroup
    {
        param(
            [String] $Named,

            [switch] $Not,

            [switch] $Exists,

            [String] $WithDescription,

            [String[]] $WithMembers = @()
        )

        if ($Not)
        {
            Test-CLocalGroup -Name $Named | Should -BeFalse
            return
        }

        $group = Get-LocalGroup -Name $Named
        $group | Should -Not -BeNullOrEmpty

        $group.Description | Should -Be $WithDescription

        foreach ($member in $WithMembers)
        {
            Get-LocalGroupMember -Name $Named -Member $member | Should -Not -BeNullOrEmpty
        }
    }

    function WhenInstalling
    {
        [CmdletBinding()]
        param(
            [String] $GroupNamed,
            [hashtable] $WithArgs
        )

        Install-CLocalGroup -Name $GroupNamed @WithArgs
    }
}

Describe 'Install-CLocalGroup' {
    BeforeEach {
        $script:groupName = "Install-CLocalGroup$($script:testNum)"
        $script:testNum += 1
        Uninstall-CLocalGroup -Name $script:groupName
    }

    AfterEach {
        Uninstall-CLocalGroup -Name $script:groupName
    }

    It 'creates group' {
        WhenInstalling $script:groupName
        ThenGroup $script:groupName -Exists
    }

    It 'sets description and members' {
        $installArgs = @{ Description = 'fubarsnafu' ; Member = @('Everyone', 'Authenticated Users') }
        WhenInstalling $script:groupName -WithArgs $installArgs
        ThenGroup $script:groupName `
                  -Exists `
                  -WithDescription $installArgs['Description'] `
                  -WithMembers @('Everyone', 'NT AUTHORITY\Authenticated Users')
    }

    It 'supports WhatIf' {
        WhenInstalling $script:groupName -WithArgs @{ WhatIf = $true }
        ThenGroup $script:groupName -Not -Exists
    }

    It 'updates description' {
        WhenInstalling $script:groupName -WithArgs @{ Description = 'fubarsnafu' }
        ThenGroup $script:groupName -Exists -WithDescription 'fubarsnafu'
        WhenInstalling $script:groupName -WithArgs @{ Description = 'fubarsnafu2' }
        ThenGroup $script:groupName -Exists -WithDescription 'fubarsnafu2'
    }
}
