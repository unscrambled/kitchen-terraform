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

require "kitchen/terraform/client/plan"

::RSpec.describe ::Kitchen::Terraform::Client::Plan do
  require "support/kitchen/terraform/client/command_examples"

  it_behaves_like ::Kitchen::Terraform::Client::Command do
    let :color do false end

    let :command do
      "terraform plan -no-color -destroy -input=false -out=/out " \
        "-parallelism=123 -refresh=true -state=/state " \
        "-var-file=/variable/file/one -var-file=/variable/file/two " \
        "-var='key_one=value_one' -var='key_two=value_two' /directory"
    end

    let :destroy do true end

    let :directory do "/directory" end

    let :operation do
      described_class.call(
        {
          color: color, destroy: destroy, directory: directory, out: out,
          parallelism: parallelism, state: state,
          variable_files: variable_files, variables: variables
        }, logger: [], timeout: 123
      )
    end

    let :out do "/out" end

    let :parallelism do 123 end

    let :state do "/state" end

    let :variable_files do ["/variable/file/one", "/variable/file/two"] end

    let :variables do {key_one: "value_one", key_two: "value_two"} end

    before do
      allow(::FileUtils).to receive(:mkpath).with "/"

      allow(::FileUtils).to receive(:touch).with "/out"

      allow(::File).to receive(:writable?).with("/out").and_return true

      allow(::File).to receive(:readable?).with("/state").and_return true

      allow(::File).to receive(:zero?).with("/state").and_return false
    end

    describe "parameter validation" do
      require "support/kitchen/terraform/operation/contract_examples"

      context "when :color is not a boolean" do
        let :color do "abc" end

        it_behaves_like ::Kitchen::Terraform::Operation::Contract do
          let :property do "color" end
        end
      end

      context "when :destroy is not a boolean" do
        let :destroy do "abc" end

        it_behaves_like ::Kitchen::Terraform::Operation::Contract do
          let :property do "destroy" end
        end
      end

      context "when :directory is not a string" do
        let :directory do 123 end

        it_behaves_like ::Kitchen::Terraform::Operation::Contract do
          let :property do "directory" end
        end
      end

      context "when :out is not a string" do
        let :out do 123 end

        it_behaves_like ::Kitchen::Terraform::Operation::Contract do
          let :property do "out" end
        end
      end

      context "when :parallelism is not a number" do
        let :parallelism do "abc" end

        it_behaves_like ::Kitchen::Terraform::Operation::Contract do
          let :property do "parallelism" end
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
