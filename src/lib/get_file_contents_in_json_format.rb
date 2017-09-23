#!/usr/bin/env ruby
# coding: utf-8
# frozen_string_literal: true

# Script to get file contents in JSON format
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

require 'json'
require 'thor'

# CLI
class GetFileContentsInJSONFormat < Thor
  desc 'get path', 'Get file contents in JSON format'
  def get(path)
    File.open(path, 'r') do |f|
      puts JSON.generate(contents: f.read)
    end
  end
end

GetFileContentsInJSONFormat.start(ARGV) if $PROGRAM_NAME == __FILE__
