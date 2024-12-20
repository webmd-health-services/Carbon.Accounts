# Copyright WebMD Health Services
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License

using namespace System.ComponentModel
using namespace System.Runtime.InteropServices
using namespace System.Security.Principal

#Requires -Version 5.1
Set-StrictMode -Version 'Latest'

# Functions should use $script:moduleRoot as the relative root from which to find
# things. A published module has its function appended to this file, while a
# module in development has its functions in the Functions directory.
$script:moduleRoot = $PSScriptRoot
$psModulesDirPath = Join-Path -Path $script:moduleRoot -ChildPath 'Modules' -Resolve

# Import the .psm1 directly because it creates one less nested scope. PowerShell has a 10 nested scope limit.
Import-Module -Name (Join-Path -Path $psModulesDirPath -ChildPath 'PureInvoke\PureInvoke.psm1' -Resolve) `
              -Function @(
                    'Invoke-AdvapiLookupAccountName',
                    'Invoke-AdvapiLookupAccountSid',
                    'Invoke-NetApiNetLocalGroupGetMembers'
                ) `
              -Verbose:$false

enum Carbon_Accounts_Principal_Type
{
    User = 1
    Group
    Domain
    Alias
    WellKnownGroup
    DeletedAccount
    Invalid
    Unknown
    Computer
    Label
}

class Carbon_Accounts_Principal
{
    Carbon_Accounts_Principal([String] $Domain,
                             [String] $Name,
                             [SecurityIdentifier]$Sid,
                             [Carbon_Accounts_Principal_Type]$Type)
    {
        $this.Domain = $Domain;
        $this.Name = $Name;
        $this.Sid = $Sid;
        $this.Type = $Type;

        $this.FullName = $Name
        if ($Domain)
        {
            $this.FullName = "${Domain}\${Name}"
        }
    }

    [String] $Domain

    [String] $FullName

    [String] $Name

    [SecurityIdentifier] $Sid

    [Carbon_Accounts_Principal_Type] $Type

    [bool] Equals([Object] $obj)
    {
        if ($null -eq $obj -or $obj -isnot [Carbon_Accounts_Principal])
        {
            return $false;
        }

        return $this.Sid.Equals($obj.Sid);
    }

    [String] ToString()
    {
        return $this.FullName
    }
}

# Store each of your module's functions in its own file in the Functions
# directory. On the build server, your module's functions will be appended to
# this file, so only dot-source files that exist on the file system. This allows
# developers to work on a module without having to build it first. Grab all the
# functions that are in their own files.
$functionsPath = Join-Path -Path $script:moduleRoot -ChildPath 'Functions\*.ps1'
if( (Test-Path -Path $functionsPath) )
{
    foreach( $functionPath in (Get-Item $functionsPath) )
    {
        . $functionPath.FullName
    }
}
