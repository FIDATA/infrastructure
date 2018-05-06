#!/bin/sh -eux

# Install prerequisites for Vagrant
# Copyright © 2016-2018  Basil Peace
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

pubkey_url="https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub";
mkdir -p $HOME/.ssh;
if command -v wget >/dev/null 2>&1; then
    wget "$pubkey_url" -O $HOME/.ssh/authorized_keys;
elif command -v curl >/dev/null 2>&1; then
    curl --location "$pubkey_url" > $HOME/.ssh/authorized_keys;
else
    echo "Cannot download vagrant public key";
    exit 1;
fi
chown -R $USER $HOME/.ssh;
chmod -R go-rwsx $HOME/.ssh;
