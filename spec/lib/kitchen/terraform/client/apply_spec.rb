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

require "kitchen/terraform/client/apply"

::RSpec.describe ::Kitchen::Terraform::Client::Apply do
  require "support/kitchen/terraform/client/command_examples"

  it_behaves_like ::Kitchen::Terraform::Client::Command do
    require "support/kitchen/terraform/client/command/policy/readable_context"
    require "support/kitchen/terraform/client/command/policy/writable_context"

    include_context ::Kitchen::Terraform::Client::Command::Policy::Readable do
      let :readable_file do "/plan" end
    end

    include_context ::Kitchen::Terraform::Client::Command::Policy::Writable do
      let :writable_file do "/state" end
    end

    let :color do false end

    let :command do
      "terraform apply -no-color -input=false -parallelism=123 -state=/state " \
        "-var-file=/variable/file/one -var-file=/variable/file/two " \
        "-var='key_one=value_one' -var='key_two=value_two' /plan"
    end

    let :operation do
      described_class.call(
        {
          color: color, parallelism: parallelism, plan: plan, state: state,
          variable_files: variable_files, variables: variables
        }, logger: [], timeout: 123
      )
    end

    let :parallelism do 123 end

    let :plan do "/plan" end

    let :state do "/state" end

    let :variable_files do ["/variable/file/one", "/variable/file/two"] end

    let :variables do {key_one: "value_one", key_two: "value_two"} end

    before do
      allow(::FileUtils).to receive(:mkpath).with "/"

      allow(::FileUtils).to receive(:touch).with "/state"

      allow(::File).to receive(:writable?).with("/state").and_return true
    end

    describe "parameter validation" do
      require "support/kitchen/terraform/operation/contract_examples"

      context "when :color is not a boolean" do
        let :color do "abc" end

        it_behaves_like ::Kitchen::Terraform::Operation::Contract do
          let :property do "color" end
        end
      end

      context "when :parallelism is not a number" do
        let :parallelism do "abc" end

        it_behaves_like ::Kitchen::Terraform::Operation::Contract do
          let :property do "parallelism" end
        end
      end

      context "when :plan is not a string" do
        let :plan do 123 end

        it_behaves_like ::Kitchen::Terraform::Operation::Contract do
          let :property do "plan" end
        end
      end

      context "when :state is not a string" do
        let :state do 123 end

        it_behaves_like ::Kitchen::Terraform::Operation::Contract do
          let :property do "state" end
        end
      end

      context "when :variable_files is not a list of strings" do
        let :variable_files do "abc" end

        it_behaves_like ::Kitchen::Terraform::Operation::Contract do
          let :property do "variable_files" end
        end
      end

      context "when :variables is not a mapping of keys and values" do
        let :variables do "abc" end

        it_behaves_like ::Kitchen::Terraform::Operation::Contract do
          let :property do "variables" end
        end
      end
    end
  end
end
