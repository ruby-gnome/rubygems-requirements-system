# Copyright (C) 2025  Ruby-GNOME Project Team
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

require_relative "executable"
require_relative "package"
require_relative "requirement"
require_relative "system-repository"

module RubyGemsRequirementsSystem
  class RequirementsParser
    def initialize(gemspec_requirements, platform, ui)
      @gemspec_requirements = gemspec_requirements
      @platform = platform
      @ui = ui
    end

    def parse
      all_dependencies_set = {}
      requirements = {}
      @gemspec_requirements.each do |gemspec_requirement|
        components = gemspec_requirement.split(/:\s*/, 4)
        next unless components.size == 4

        id, raw_dependencies, platform, system_package = components
        next unless id == "system"

        dependencies = parse_dependencies(raw_dependencies)
        next if dependencies.empty?

        all_dependencies_set[dependencies] = true

        next unless @platform.target?(platform)
        requirements[dependencies] ||= []
        requirements[dependencies] << system_package
      end
      (all_dependencies_set.keys - requirements.keys).each do |not_used_deps|
        not_used_packages = not_used_deps.select do |dependency|
          dependency.is_a?(Package)
        end
        next if not_used_packages.empty?
        system_packages = @platform.default_system_packages(not_used_packages)
        next if system_packages.nil?
        requirements[not_used_deps] = system_packages
      end
      requirements.collect do |dependencies, system_packages|
        system_packages = detect_system_repositories(system_packages)
        Requirement.new(dependencies, system_packages)
      end
    end

    private
    def parse_dependencies(raw_dependencies)
      dependencies = []
      raw_dependencies.split(/\s*\|\s*/).each do |raw_dependency|
        match_data = /\A([^(]+)\((.+)\)\z/.match(raw_dependency)
        if match_data
          type = match_data[1]
          value = match_data[2]
        else
          type = "pkgconfig"
          value = raw_dependency
        end
        dependency = parse_dependency(type, value, raw_dependency)
        next if dependency.nil?
        dependencies << dependency
      end
      dependencies
    end

    def parse_dependency(type, value, raw_dependency)
      # We must not report an error for invalid dependency because
      # Gem::Specification#requirements is a free form
      # configuration. So there are configuration values that use
      # "system: ..." but not for this plugin. We can report a warning
      # instead.
      case type
      when "executable"
        Executable.new(value)
      when "pkgconfig"
        id, operator, required_version = value.split(/\s*(==|>=|>|<=|<)\s*/, 3)
        if id.empty?
          @ui.warn("Ignore invalid package: no ID: #{raw_dependency}")
          return nil
        end
        if operator and required_version.nil?
          @ui.warn("Ignore invalid package: " +
                   "no required version with operator: #{raw_dependency}")
          return nil
        end
        Package.new(id, operator, required_version)
      else
        @ui.warn("Ignore unsupported type: #{type}: #{raw_dependency}")
        nil
      end
    end

    def detect_system_repositories(original_system_packages)
      system_packages = []
      repository_properties = {}

      flush_repository = lambda do
        return if repository_properties.empty?
        properties = repository_properties
        repository_properties = {}

        id = properties.delete("id")
        return if id.nil?
        repository = SystemRepository.new(id, properties)
        return unless @platform.valid_system_repository?(repository)
        system_packages << repository
      end

      original_system_packages.each do |system_package|
        unless system_package.start_with?("repository:")
          flush_repository.call
          next unless @platform.valid_system_package?(system_package)
          system_packages << system_package
          next
        end
        _, key, value = system_package.strip.split(/:\s*/, 3)
        next if value.empty?
        if key == "id" and repository_properties.key?("id")
          flush_repository.call
        end
        repository_properties[key] = value
      end
      flush_repository.call

      system_packages
    end
  end
end
