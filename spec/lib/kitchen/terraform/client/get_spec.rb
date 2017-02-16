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

require "kitchen/terraform/client/get"

::RSpec.describe ::Kitchen::Terraform::Client::Get do
  require "support/kitchen/terraform/client/command_examples"

  it_behaves_like ::Kitchen::Terraform::Client::Command do
    let :command do "terraform get -update /directory" end

    let :directory do "/directory" end

    let :operation do
      described_class.call({directory: directory}, logger: [], timeout: 123)
    end

    describe "parameter validation" do
      require "support/kitchen/terraform/operation/contract_examples"

      context "when :directory is not a string" do
        let :directory do 123 end

        it_behaves_like ::Kitchen::Terraform::Operation::Contract do
          let :property do "directory" end
        end
      end
    end
  end
end
