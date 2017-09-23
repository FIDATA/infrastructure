#!/usr/bin/env ruby
# coding: utf-8
# frozen_string_literal: true

# Script to get artifact metadata from Atlas (http://atlas.hashicorp.com/)
# using Terraform CLI under the hood
# Copyright © 2017  Basil Peace
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

require 'tempfile'
require 'open3'
require 'json'
require 'thor'

def get_atlas_artifact_metadata_full(name, type, version)
  Dir::Tmpname.create(['', '.tfstate'], ENV['TEMP']) do |state_file|
    STDERR.write Open3.capture2(
      'terraform', 'apply',
      "-state=#{state_file}",
      '-var', "atlas_token=#{ENV['ATLAS_TOKEN']}",
      '-var', "name=#{name}",
      '-var', "type=#{type}",
      '-var', "version=#{version}",
      chdir: File.expand_path(File.dirname(__FILE__))
    )[0]
    return JSON.parse(Open3.capture2(
      'terraform', 'output',
      "-state=#{state_file}",
      '-json',
      chdir: File.expand_path(File.dirname(__FILE__))
    )[0])['metadata_full']['value']
  end
end

# CLI
class GetAtlasArtifactMetadataFull < Thor
  desc 'get name type version', 'Get Atlas artifact full metadata'
  def get(name, type, version)
    puts JSON.generate(get_atlas_artifact_metadata_full(name, type, version))
  end
end

GetAtlasArtifactMetadataFull.start(ARGV) if $PROGRAM_NAME == __FILE__
