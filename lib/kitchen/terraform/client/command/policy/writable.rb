# frozen_string_literal: true

# Copyright 2016 New Context Services, Inc.
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
# limitations under the License.

require "fileutils"
require "kitchen/terraform/client/command/policy"
require "kitchen/terraform/operation/callable"

::Kitchen::Terraform::Client::Command::Policy::Writable =
  ::Class.new ::Kitchen::Terraform::Operation::Callable do
    define_singleton_method :call do |options, params:, **|
      require "kitchen/terraform/client/command/cell/not_writable"

      begin
        ::FileUtils.mkpath ::File.dirname params[:file]
        ::FileUtils.touch params[:file]
      rescue Errno::EACCES, SystemCallError
      end

      ::File.writable? params[:file] and return true

      options["error"] =
        ::Kitchen::Terraform::Client::Command::Cell::NotWritable
          .call(params[:file]).call

      return false
    end
  end
