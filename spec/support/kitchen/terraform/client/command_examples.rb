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

require "kitchen/terraform/client/command"

::RSpec.shared_examples ::Kitchen::Terraform::Client::Command do
  let :shell_out do instance_double ::Mixlib::ShellOut end

  let :shell_out_class do
    class_double(::Mixlib::ShellOut)
      .as_stubbed_const transfer_nested_constants: true
  end

  let :stderr do "stderr" end

  let :stdout do "stdout" end

  before do
    allow(shell_out_class).to receive(:new).with(
      command, live_stream: duck_type(:<<), timeout: kind_of(::Numeric)
    ).and_return shell_out

    allow(shell_out).to receive(:run_command).with no_args

    allow(shell_out).to receive(:stdout).with(no_args).and_return stdout

    allow(shell_out).to receive(:stderr).with(no_args).and_return stderr

    allow(shell_out).to receive(:error!).with no_args
  end

  context "when the command is successful" do
    describe "the stdout" do
      subject do operation["stdout"] end

      it "is saved" do is_expected.to eq stdout end
    end

    describe "the stderr" do
      subject do operation["stderr"] end

      it "is saved" do is_expected.to eq stderr end
    end
  end

  context "when the command is not successful" do
    before do
      allow(shell_out)
        .to receive(:run_command).with(no_args).and_raise "error"

      allow(shell_out).to receive(:command).with(no_args).and_return "command"
    end

    describe "the error" do
      subject do operation["error"] end

      it "is saved" do is_expected.to eq "`command` failed: 'error'" end
    end
  end
end
