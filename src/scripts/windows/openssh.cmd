@echo off
REM Install and configure OpenSSH
REM Copyright (C) 2018  Basil Peace
REM
REM This file is part of FIDATA Infrastructure.
REM
REM Licensed under the Apache License, Version 2.0 (the "License");
REM you may not use this file except in compliance with the License.
REM You may obtain a copy of the License at
REM
REM     http://www.apache.org/licenses/LICENSE-2.0
REM
REM Unless required by applicable law or agreed to in writing, software
REM distributed under the License is distributed on an "AS IS" BASIS,
REM WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
REM implied.
REM See the License for the specific language governing permissions and
REM limitations under the License.

choco install openssh --version=7.6.0.1 --params='"/SSHServerFeature /DeleteServerKeysAfterInstalled /PathSpecsToProbeForShellEXEString:$Env:ProgramFiles\PowerShell*\Powershell.exe;$Env:SystemRoot\system32\windowspowershell\v1.0\powershell.exe /SSHDefaultShellCommandOption:/c"' --yes --stop-on-first-failure
md "%USERPROFILE%\.ssh"
