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

Write-Host 'Clearing Personal Certificate Store...'
$DestStore = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Store -ArgumentList ([System.Security.Cryptography.X509Certificates.StoreName]::My), ([System.Security.Cryptography.X509Certificates.StoreLocation]::LocalMachine)
$DestStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
$DestStore.RemoveRange($DestStore.Certificates)
$DestStore.Close()

# Write-Host 'Deleting Existing WinRM Listener...'
# winrm delete winrm/config/Listener?Address=*+Transport=HTTPS
