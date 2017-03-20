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

require "kitchen/terraform"

::Kitchen::Terraform::ResolveGroupAttributes = ::Module.new do
  define_singleton_method :call do |attributes:, client:, state:, &block|
    ::Hash.new.tap do |resolved_attributes|
      resolved_attributes.store "terraform_state", state
      client.each_output_name do |output_name|
        resolved_attributes.store output_name, client.output(name: output_name)
      end
      attributes.each_pair do |attribute_name, output_name|
        resolved_attributes
          .store attribute_name.to_s, client.output(name: output_name)
      end
      block.call resolved_attributes
    end
  end
end
