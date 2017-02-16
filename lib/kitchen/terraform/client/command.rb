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

require "kitchen/terraform/client"
require "kitchen/terraform/operation"

::Kitchen::Terraform::Client::Command =
  ::Class.new ::Kitchen::Terraform::Operation
::Kitchen::Terraform::Client::Command.class_eval do
  step :initialize!
  step(Rescue(handler: :execute_failure!) do step :execute! end)

  define_method :execute! do |options, **|
    options["shell_out"].tap do |shell_out|
      shell_out.run_command
      options["stdout"] = shell_out.stdout
      options["stderr"] = shell_out.stderr
      shell_out.error!
    end
  end

  define_method :execute_failure! do |exception, options|
    require "kitchen/terraform/client/command/cell/error"

    options["error"] =
      ::Kitchen::Terraform::Client::Command::Cell::Error
        .call(options["shell_out"], message: exception.message).call
  end

  define_method :initialize! do |options, logger:, command:, timeout:, **|
    require "mixlib/shellout"

    options["shell_out"] =
      ::Mixlib::ShellOut.new command, live_stream: logger, timeout: timeout
  end
end
