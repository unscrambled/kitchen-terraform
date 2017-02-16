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

require "kitchen/terraform/config"

::RSpec.shared_examples(
  ::Kitchen::Terraform::Config
) do |attribute:, default:, invalid:, valid:|
  describe "config[:#{attribute}]" do
    let :finalized_configurable do configurable.finalize_config! instance end

    context "when no value is specified" do
      let :configurable do described_class.new default_config end

      subject do finalized_configurable[attribute] end

      it "defaults to #{default}" do is_expected.to eq default end
    end

    context "when a valid value is specified" do
      let :configurable do
        described_class.new default_config.merge attribute => valid
      end

      subject do finalized_configurable[attribute] end

      it "persists the value" do is_expected.to eq valid end
    end

    context "when an invalid value is specified" do
      let :configurable do
        described_class.new default_config.merge attribute => invalid
      end

      subject do proc do finalized_configurable end end

      it "raises a user error" do
        is_expected.to raise_error ::Kitchen::UserError, /#{attribute}/
      end
    end
  end
end
