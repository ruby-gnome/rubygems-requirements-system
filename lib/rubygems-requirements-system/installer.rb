# Copyright (C) 2017-2025  Ruby-GNOME Project Team
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require "shellwords"

require "pkg-config"

require_relative "version"

require_relative "platform"

module RubyGemsRequirementsSystem
  Package = Struct.new(:id, :operator, :version) do
    def valid?
      return false if id.empty?
      return false if operator and version.nil?
      true
    end
  end

  Requirement = Struct.new(:packages, :system_packages) do
    def satisfied?
      packages.any? do |package|
        installed?(package)
      end
    end

    private
    def installed?(package)
      package_config = PKGConfig.package_config(package.id)
      begin
        package_config.cflags
      rescue PackageConfig::NotFoundError
        return false
      end

      return true if package.version.nil?

      current_version = Gem::Version.new(package_config.version)
      required_version = Gem::Version.new(package.version)
      current_version.__send__(package.operator, required_version)
    end
  end

  class Installer
    include Gem::UserInteraction

    def initialize(gemspec)
      @gemspec = gemspec
      @platform = Platform.detect
    end

    def install
      return true unless enabled?

      requirements = parse_requirements(@gemspec.requirements)
      requirements.all? do |requirement|
        next true if requirement.satisfied?
        @platform.install(requirement)
      end
    end

    private
    def enabled?
      case ENV["RUBYGEMS_REQUIREMENTS_SYSTEM"]
      when "0", "no", "NO", "false", "FALSE"
        return false
      end

      requirements_system = Gem.configuration["requirements_system"] || {}
      return false if requirements_system["enabled"] == false

      true
    end

    def parse_requirements(gemspec_requirements)
      all_packages_set = {}
      requirements = {}
      gemspec_requirements.each do |gemspec_requirement|
        components = gemspec_requirement.split(/: +/, 4)
        next unless components.size == 4

        id, raw_packages, platform, system_package = components
        next unless id == "system"

        packages = parse_packages(raw_packages)
        next if packages.empty?

        all_packages_set[packages] = true

        next unless @platform.target?(platform)
        requirements[packages] ||= []
        requirements[packages] << system_package
      end
      (all_packages_set.keys - requirements.keys).each do |not_used_packages|
        system_packages = @platform.default_system_packages(not_used_packages)
        next if system_packages.nil?
        requirements[not_used_packages] = system_packages
      end
      requirements.collect do |packages, system_packages|
        Requirement.new(packages, system_packages)
      end
    end

    def parse_packages(raw_packages)
      packages = raw_packages.split(/\s*\|\s*/).collect do |raw_package|
        Package.new(*raw_package.split(/\s*(==|!=|>=|>|<=|<)\s*/, 3))
      end
      # Ignore this requirement if any invalid package is included.
      # We must not report an error for this because
      # Gem::Specification#requirements is a free form
      # configuration. So there are configuration values that use
      # "system: ..." but not for this plugin. We can report a
      # warning instead.
      packages.each do |package|
        unless package.valid?
          # TODO: Report a warning
          return []
        end
      end
      packages
    end
  end
end
