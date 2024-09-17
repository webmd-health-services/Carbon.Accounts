<#
.SYNOPSIS
Gets your computer ready to develop the Carbon.Accounts module.

.DESCRIPTION
The init.ps1 script makes the configuraion changes necessary to get your computer ready to develop for the
Carbon.Accounts module. It:


.EXAMPLE
.\init.ps1

Demonstrates how to call this script.
#>
[CmdletBinding()]
param(
)

#Requires -Version 5.1
#Requires -RunAsAdministrator
Set-StrictMode -Version 'Latest'
$ErrorActionPreference = 'Stop'
$InformationPreference = 'Continue'

prism install

Import-Module -Name (Join-Path -Path $PSScriptRoot -ChildPath 'PSModules\Carbon' -Resolve) `
              -Function 'Install-CUser', 'New-CCredential'

$username = 'CarbonTestUser1'
Install-CUser -Credential (New-CCredential -UserName $username -Password 'P@ssw0rd!')

Install-CUser -Credential (New-CCredential -UserName 'CarbonTestUser2' -Password 'P@ssw0rd!')
