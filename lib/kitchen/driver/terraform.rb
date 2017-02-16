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

require "kitchen"
require_relative "../../terraform/configurable"
require_relative "../terraform/config/client"
require_relative "../terraform/config/color"
require_relative "../terraform/config/directory"
require_relative "../terraform/config/parallelism"
require_relative "../terraform/config/plan"
require_relative "../terraform/config/state"
require_relative "../terraform/config/timeout"
require_relative "../terraform/config/variable_files"
require_relative "../terraform/config/variables"
require_relative "../terraform/debug_logger"

# Terraform state lifecycle activities manager
::Kitchen::Driver::Terraform = ::Class.new ::Kitchen::Driver::Base do
  ::Kitchen::Terraform::Config.call attributes: [
    ::Kitchen::Terraform::Config::Client,
    ::Kitchen::Terraform::Config::Color,
    ::Kitchen::Terraform::Config::Directory,
    ::Kitchen::Terraform::Config::Parallelism,
    ::Kitchen::Terraform::Config::Plan,
    ::Kitchen::Terraform::Config::State,
    ::Kitchen::Terraform::Config::Timeout,
    ::Kitchen::Terraform::Config::VariableFiles,
    ::Kitchen::Terraform::Config::Variables
  ], plugin_class: self

  include ::Terraform::Configurable

  kitchen_driver_api_version 2

  no_parallel_for

  def create(_state = nil)
    ::Kitchen::Driver::Terraform::Create
      .call config, "logger" => logger, "timeout" => config[:timeout]
  rescue => error
    raise ::Kitchen::ActionFailed, error.message
  end

  def destroy(_state = nil)
    load_state { client.plan_and_apply destroy: true }
  rescue ::Kitchen::StandardError, ::SystemCallError => error
    raise ::Kitchen::ActionFailed, error.message
  end

  def verify_dependencies
    ::Kitchen::Driver::Terraform::VerifyDependencies.call(
      "logger" => ::Kitchen::Terraform::DebugLogger.new(logger)
    )["result.kitchen.terraform.callback"].call
  end

  private

  def load_state(&block)
    silent_client.load_state(&block)
  rescue ::Errno::ENOENT => error
    debug error.message
  end
end

require_relative "terraform/verify_dependencies"
