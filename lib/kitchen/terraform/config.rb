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

require_relative "../terraform"

::Kitchen::Terraform::Config = ::Module.new do
  def self.call(attributes:, plugin_class:)
    attributes.each do |attribute|
      plugin_class.required_config attribute["key"] do |key, value|
        attribute.call(key => value).tap do |result|
          result.success? or
            raise ::Kitchen::UserError, result["result.operation.error_message"]
        end
      end
      plugin_class.default_config attribute["key"], attribute["default"]
    end
  end
end
