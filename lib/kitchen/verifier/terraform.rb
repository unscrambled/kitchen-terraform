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
require "kitchen/terraform/group_attributes_resolver"
require "kitchen/terraform/group_hostnames_resolver"
require "kitchen/verifier/inspec"
require "terraform/configurable"

# Runs tests post-converge to confirm that instances in the Terraform state
# are in an expected state
::Kitchen::Verifier::Terraform = ::Class.new ::Kitchen::Verifier::Inspec do
  ::Kitchen::Config::Groups.call plugin_class: self

  include ::Terraform::Configurable

  kitchen_verifier_api_version 2

  define_method :call do |state|
    begin
      config.fetch(:groups).each do |group|
        config.store :controls, group.fetch(:controls)
        config.store :port, group.fetch(:port, transport[:port])
        config.store :username, group.fetch(:username, transport[:username])
        group_attributes_resolver
          .resolve attributes: group.fetch(:attributes), client: silent_client,
                   state: provisioner[:state] do |resolved_attributes|
            config.store :attributes, resolved_attributes
          end
        group_hostnames_resolver
          .resolve client: silent_client,
                   hostnames: group.fetch(:hostnames) do |resolved_hostname|
            config.store :host, resolved_hostname
            info "Verifying '#{resolved_hostname}' of group '#{group.fetch :name}'"
            super
          end
      end
    rescue ::Kitchen::StandardError, ::SystemCallError => error
      raise ::Kitchen::ActionFailed, error.message
    end
  end

  private

  attr_accessor :group_attributes_resolver, :group_hostnames_resolver

  define_method :initialize do |config = {}|
    super config
    self.group_attributes_resolver =
      ::Kitchen::Terraform::GroupAttributesResolver.new
    self.group_hostnames_resolver =
      ::Kitchen::Terraform::GroupHostnamesResolver.new
  end

  define_method(
    :runner_options
  ) do |transport, state = {}, platform = nil, suite = nil|
    super(transport, state, platform, suite).tap do |options|
      options.store :controls, config.fetch(:controls)
      /^localhost$/.match config.fetch :host do |match|
        options.store "backend", "local"
      end
    end
  end
end
