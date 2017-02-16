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

require "kitchen/terraform/client/command/policy/readable"

::RSpec
  .shared_context ::Kitchen::Terraform::Client::Command::Policy::Readable do
    before do
      allow(::File).to receive(:readable?).with(readable_file).and_return true
    end

    context "when the file is not readable" do
      require "support/kitchen/terraform/operation_examples"

      before do
        allow(::File)
          .to receive(:readable?).with(readable_file).and_return false
      end

      it_behaves_like ::Kitchen::Terraform::Operation, result: :failure

      describe "the error" do
        subject do operation["error"] end

        it "indicates the file is not readable" do
          is_expected.to eq "#{readable_file} is not readable"
        end
      end
    end
  end
