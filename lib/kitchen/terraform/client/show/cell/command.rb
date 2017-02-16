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

require "kitchen/terraform/client/show/cell"
require "kitchen/terraform/operation/cell"

::Kitchen::Terraform::Client::Show::Cell::Command =
  ::Class.new ::Kitchen::Terraform::Operation::Cell do
    require "kitchen/terraform/client/command/cell/color"
    require "kitchen/terraform/client/command/cell/state"

    define_method :show do
      [
        "terraform", "show",
        ::Kitchen::Terraform::Client::Command::Cell::Color.call(model).call,
        ::Kitchen::Terraform::Client::Command::Cell::State.call(model).call
      ].join " "
    end
  end
