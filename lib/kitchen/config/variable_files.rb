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

::Kitchen::Config::VariableFiles = ::Module.new do
  define_singleton_method :call do |plugin_class:|
    require "kitchen/config/variable_files/schema"

    plugin_class.required_config :variable_files do |attribute, value, plugin|
      ::Kitchen::Config::VariableFiles::Schema
        .call(value: value).messages.tap do |messages|
          raise ::Kitchen::UserError,
                "#{plugin.class} configuration: #{attribute} #{messages}" unless
                  messages.empty?
        end
    end
    plugin_class.default_config :variable_files, []
  end
end
