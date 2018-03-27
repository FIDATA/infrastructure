# Sysprep Windows
# Copyright © 2018  Basil Peace
#
# This file is part of FIDATA Infrastructure.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.

Write-Host 'Adding Custom Generalize and Specialize scripts...'
Add-Content -Path "$Env:ProgramData\Amazon\EC2-Windows\Launch\Sysprep\BeforeSysprep.cmd" -Value @('', `
  'powershell %~dp0\BeforeSysprep.ps1 >> %TEMP%\BeforeSysprep.log 2>& 1' `
)
Add-Content -Path "$Env:ProgramData\Amazon\EC2-Windows\Launch\Sysprep\SysprepSpecialize.cmd" -Value @('', `
  'powershell %~dp0\ConfigureWinRMWithSelfSignedCertificate.ps1 >> %TEMP%\SysprepSpecialize.log 2>& 1' `
)

Write-Host 'Running Sysprep...'
& "$Env:ProgramData\Amazon\EC2-Windows\Launch\Scripts\InitializeInstance.ps1" -Schedule
& "$Env:ProgramData\Amazon\EC2-Windows\Launch\Scripts\SysprepInstance.ps1" -NoShutdown
