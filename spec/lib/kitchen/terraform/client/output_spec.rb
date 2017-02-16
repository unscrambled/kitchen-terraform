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

require "kitchen/terraform/client/output"

::RSpec.describe ::Kitchen::Terraform::Client::Output do
  require "support/kitchen/terraform/client/command_examples"

  it_behaves_like ::Kitchen::Terraform::Client::Command do
    let :command do "terraform output -json -state=/state name" end

    let :name do "name" end

    let :operation do
      described_class.call({name: name, state: state}, logger: [], timeout: 123)
    end

    let :state do "/state" end

    let :stdout do
      require "json"

      ::JSON.dump "key" => "value"
    end

    describe "parameter validation" do
      require "support/kitchen/terraform/operation/contract_examples"

      context "when :name is not a string" do
        let :name do 123 end

        it_behaves_like ::Kitchen::Terraform::Operation::Contract do
          let :property do "name" end
        end
      end

      context "when :state is not a string" do
        let :state do 123 end

        it_behaves_like ::Kitchen::Terraform::Operation::Contract do
          let :property do "state" end
        end
      end
    end

    describe "the output" do
      subject do operation["output"] end

      it "is parsed from stdout JSON" do is_expected.to eq "key" => "value" end
    end
  end
end
