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

require "kitchen/terraform/debug_logger"

::RSpec.describe ::Kitchen::Terraform::DebugLogger do
  let(:described_instance) { described_class.new logger }

  let(:logger) { instance_double ::Kitchen::Logger }

  describe "#<<" do
    after { described_instance << "message" }

    subject { logger }

    it "dumps the message to debug" do
      is_expected.to receive(:debug).with "message"
    end
  end
end
