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

require_relative "version"

require_relative "platform"
require_relative "requirements-parser"
require_relative "ui"

module RubyGemsRequirementsSystem
  pkg_config_rb = File.join(__dir__, "pkg-config.rb")
  load(pkg_config_rb, self)
  unless const_defined?(:PKGConfig)
    # Ruby < 3.1
    File.open(pkg_config_rb) do |pkg_config_rb_file|
      module_eval(pkg_config_rb_file.read, pkg_config_rb)
    end
  end

  class Installer
    def initialize(gemspec, ui)
      @gemspec = gemspec
      @ui = UI.new(ui)
      @platform = Platform.detect(@ui)
    end

    def install
      return true unless enabled?

      parser = RequirementsParser.new(@gemspec.requirements, @platform, @ui)
      requirements = parser.parse
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
      case requirements_system["enabled"]
      when false
        return false
      when "false" # "true"/"false" isn't converted to boolean with old RubyGems
        return false
      end

      true
    end
  end
end
