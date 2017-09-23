#!/bin/sh -eux

# Configure sudoers on Linux
# Based on script from Chef Bento
# Copyright 2012-2016, Chef Software, Inc. (<legal@chef.io>)
# Copyright 2011-2012, Tim Dysinger (<tim@dysinger.net>)
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

major_version="`lsb_release -r | awk '{print $2}' | awk -F. '{print $1}'`";

if [ ! -z "$major_version" -a "$major_version" -lt 12 ]; then
    sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers;
    sed -i -e 's/%admin\s*ALL=(ALL) ALL/%admin\tALL=(ALL) NOPASSWD:ALL/g' /etc/sudoers;
else
    sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=sudo' /etc/sudoers;
    sed -i -e 's/%sudo\s*ALL=(ALL:ALL) ALL/%sudo\tALL=(ALL) NOPASSWD:ALL/g' /etc/sudoers;
fi
