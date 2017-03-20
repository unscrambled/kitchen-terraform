# frozen_string_literal: true

# Copyright 2016-2017 New Context Services, Inc.
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

require "kitchen/terraform/resolve_group_attributes"
require "terraform/client"

::RSpec.describe ::Kitchen::Terraform::ResolveGroupAttributes do
  describe "#resolve" do
    let :client do instance_double ::Terraform::Client end

    before do
      allow(client).to receive(:each_output_name)
        .with(no_args).and_yield("output_name_1").and_yield "output_name_2"

      allow(client).to receive(:output)
        .with(name: "output_name_1").and_return "output_value_1"

      allow(client).to receive(:output)
        .with(name: "output_name_2").and_return "output_value_2"
    end

    subject do
      lambda do |block|
        described_class.call attributes: { output_name_1: "output_name_2" },
                             client: client, state: "/state/file", &block
      end
    end

    it "associates defined output names and values" do
      is_expected
        .to yield_with_args including "output_name_2" => "output_value_2"
    end

    it "associates user specified attribute names and output values with " \
         "precedence" do
      is_expected
        .to yield_with_args including "output_name_1" => "output_value_2"
    end

    it "associates 'terraform_state' with the Terraform state path" do
      is_expected
        .to yield_with_args including "terraform_state" => "/state/file"
    end
  end
end
