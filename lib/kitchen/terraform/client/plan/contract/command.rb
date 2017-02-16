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

require "kitchen/terraform/client/apply/contract"
require "kitchen/terraform/operation/contract"

::Kitchen::Terraform::Client::Plan::Contract::Command =
  ::Class.new ::Kitchen::Terraform::Operation::Contract do
    property :color
    property :destroy
    property :directory
    property :out
    property :parallelism
    property :state
    property :variable_files
    property :variables

    validation do
      required(:color).filled :bool?
      required(:destroy).filled :bool?
      required(:directory).filled :str?
      required(:out).filled :str?
      required(:parallelism).filled :int?
      required(:state).filled :str?
      required(:variable_files).each :filled?, :str?
      required(:variables).filled :hash?
    end
  end
