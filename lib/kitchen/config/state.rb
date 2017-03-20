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

require "kitchen"

::Kitchen::Config::State = ::Module.new do
  define_singleton_method :call do |plugin_class:|
    require "kitchen/config/state/schema"

    plugin_class.required_config :state do |attribute, value, plugin|
      ::Kitchen::Config::State::Schema
        .call(value: value).messages.tap do |messages|
          raise ::Kitchen::UserError,
                "#{plugin.class} configuration: #{attribute} #{messages}" unless
                  messages.empty?
        end
    end
    plugin_class.default_config :state do |plugin|
      plugin.instance_pathname filename: "terraform.tfstate"
    end
  end
end
