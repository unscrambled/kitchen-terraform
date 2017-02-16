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

require "mixlib/shellout"
require "kitchen/terraform/client/operation"

::RSpec.shared_context(
  ::Kitchen::Terraform::Client::Operation
) do |command_string:, error: false, stderr: "stderr", stdout: "stdout"|
  let(:shell_out) { instance_double ::Mixlib::ShellOut }

  let(:shell_out_class) { class_double(::Mixlib::ShellOut).as_stubbed_const }

  before do
    allow(shell_out_class).to receive(:new).with(
      command_string, live_stream: duck_type(:<<), timeout: kind_of(::Numeric)
    ).and_return shell_out

    allow(shell_out).to receive(:run_command).with no_args

    allow(shell_out).to receive(:stdout).with(no_args).and_return stdout

    allow(shell_out).to receive(:stderr).with(no_args).and_return stderr

    error and allow(shell_out)
      .to receive(:error!).with(no_args).and_raise ::Errno::EACCES or
        allow(shell_out).to receive(:error!).with no_args
  end
end
