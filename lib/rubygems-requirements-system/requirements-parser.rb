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

require_relative "package"
require_relative "requirement"

module RubyGemsRequirementsSystem
  class RequirementsParser
    def initialize(gemspec_requirements, platform)
      @gemspec_requirements = gemspec_requirements
      @platform = platform
    end

    def parse
      all_packages_set = {}
      requirements = {}
      @gemspec_requirements.each do |gemspec_requirement|
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

    private
    def parse_packages(raw_packages)
      packages = raw_packages.split(/\s*\|\s*/).collect do |raw_package|
        Package.parse(raw_package)
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
