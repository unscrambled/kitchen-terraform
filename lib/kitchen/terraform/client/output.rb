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

::Kitchen::Terraform::Client::Output =
  ::Class.new ::Kitchen::Terraform::Operation
::Kitchen::Terraform::Client::Output.class_eval do
  require "kitchen/terraform/client/command"
  require "kitchen/terraform/client/output/contract/command"
  require "kitchen/terraform/client/output/input/command"
  require "kitchen/terraform/operation/step/contract_failure"
  require "ostruct"

  step Model ::OpenStruct, :new
  step ::Trailblazer::Operation::Contract
    .Build constant: ::Kitchen::Terraform::Client::Output::Contract::Command
  step ::Trailblazer::Operation::Contract.Validate
  failure ::Kitchen::Terraform::Operation::Step::ContractFailure
  step ::Trailblazer::Operation::Contract.Persist method: :sync
  step Nested ::Kitchen::Terraform::Client::Command,
       input: ::Kitchen::Terraform::Client::Output::Input::Command
  step :parse_stdout!

  define_method :parse_stdout! do |options, **|
    require "json"

    options["output"] = ::JSON.parse options["stdout"]
  end
end
