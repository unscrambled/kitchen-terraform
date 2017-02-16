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

require_relative "../../terraform/client/version"
require_relative "../../terraform/operation"
require_relative "../terraform"
require_relative "contract/verify_dependencies"

::Kitchen::Driver::Terraform::VerifyDependencies =
  ::Class.new ::Kitchen::Terraform::Operation do
    step :verify_version!
    failure :verify_version_failure!

    def verify_version!(options, **keyword_arguments)
      ::Kitchen::Terraform::Client::Version
        .call(options, **keyword_arguments).tap do |result|
          callback callable: result["result.kitchen.terraform.callback"],
                   options: options
          return result.success? &
            /0\.[78]\.\d+/.match(result["result.kitchen.terraform.stdout"])
        end
    end

    def verify_version_failure!(options, **)
      callback(
        callable: proc do
          raise ::Kitchen::UserError, "Terraform version must be 0.8.X or 0.7.X"
        end,
        options: options
      )
    end

    private

    def callback(callable:, options:)
      options["result.kitchen.terraform.callback"] ||= callback
    end
  end
