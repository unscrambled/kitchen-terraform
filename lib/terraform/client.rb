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

require 'terraform/client/operation/base'
require 'terraform/client/operation/apply'
require 'terraform/client/operation/get'
require 'terraform/client/operation/output'
require 'terraform/client/operation/plan'
require 'terraform/client/operation/show'
require 'terraform/client/operation/validate'
require 'terraform/client/operation/version'
require 'terraform/deprecated_output_parser'
require 'terraform/output_parser'
require 'terraform/version'

module Terraform
  # Client to execute commands
  class Client
    def apply
      ::Terraform::Client::Operation::Apply
        .call var: config[:variables], var_file: config[:variable_files],
              **config
    end

    def each_output_name(&block)
      output_parser(name: '').each_name(&block)
    end

    def get
      ::Terraform::Client::Operation::Get.call dir: config[:directory]
    end

    def iterate_output(name:, &block)
      output_parser(name: name).iterate_parsed_output(&block)
    end

    def load_state
      ::Terraform::Client::Operation::Show
        .call(**config)['result.execute.stdout'].empty? || yield
    end

    def output(name:)
      output_parser(name: name).parsed_output
    end

    def plan(destroy:)
      ::Terraform::Client::Operation::Plan
        .call destroy: destroy, dir: config[:directory],
              out: config[:plan], var: config[:variables],
              var_file: config[:variable_files], **config
    end

    def plan_and_apply(destroy: false)
      validate
      get
      plan destroy: destroy
      apply
    end

    def validate
      ::Terraform::Client::Operation::Validate.call dir: config[:directory]
    end

    def version
      @version ||=
        ::Terraform::Version.create value: ::Terraform::Client::Operation::Version.call
    end

    private

    attr_accessor :config

    def initialize(config: {})
      self.config = config
      ::Terraform::Client::Operation::Base['execute.logger'] = logger
    end

    def load_output(name:)
      yield ::Terraform::Client::Operation::Output.call(
        json: version.json_supported?, name: name, **config
      )['result.execute.stdout']
    end

    def output_parser(name:)
      load_output name: name do |output|
        version.json_supported? and
          return ::Terraform::OutputParser.new output: output or
          return ::Terraform::DeprecatedOutputParser.new output: output
      end
    end
  end
end
