
#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

BeforeAll {
    Set-StrictMode -Version 'Latest'
    & (Join-Path -Path $PSScriptRoot -ChildPath 'Initialize-Test.ps1' -Resolve)
}

Describe 'Test-CLocalGroup' {
    BeforeEach {
        $Global:Error.Clear()
    }
    It 'finds local groups' {
        $groups = Get-LocalGroup
        $groups | Should -Not -BeNullOrEmpty
        $groups | ForEach-Object { Test-CLocalGroup -Name $_.Name } | Should -BeTrue
        $Global:Error | Should -BeNullOrEmpty
    }

    It 'handles non-existent group' {
        Test-CLocalGroup -Name 'jfnrqnwuiocnja' | Should -BeFalse
        $Global:Error | Should -BeNullOrEmpty
    }

}
