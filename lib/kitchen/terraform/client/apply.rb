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

::Kitchen::Terraform::Client::Apply =
  ::Class.new ::Kitchen::Terraform::Operation
::Kitchen::Terraform::Client::Apply.class_eval do
  require "kitchen/terraform/client/apply/contract/command"
  require "kitchen/terraform/client/apply/input/command"
  require "kitchen/terraform/client/apply/policy/command"
  require "kitchen/terraform/client/command"
  require "kitchen/terraform/operation/step/contract_failure"
  require "ostruct"

  step Model ::OpenStruct, :new
  step ::Trailblazer::Operation::Contract
    .Build constant: ::Kitchen::Terraform::Client::Apply::Contract::Command
  step ::Trailblazer::Operation::Contract.Validate
  failure ::Kitchen::Terraform::Operation::Step::ContractFailure,
          fail_fast: true
  step ::Trailblazer::Operation::Contract.Persist method: :sync
  step ::Trailblazer::Operation::Policy
    .Guard ::Kitchen::Terraform::Client::Apply::Policy::Command
  step Nested ::Kitchen::Terraform::Client::Command,
              input: ::Kitchen::Terraform::Client::Apply::Input::Command
end
