# Copyright (C) 2021-2025  Ruby-GNOME Project Team
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

require_relative "base"

module RubyGemsRequirementsSystem
  module Platform
    class Fedora < Base
      Platform.register(self)

      class << self
        def current_platform?
          os_release = OSRelease.new
          os_release.id == "fedora" or os_release.id_like.include?("fedora")
        end
      end

      def target?(platform)
        platform == "fedora"
      end

      def default_system_packages(packages)
        packages.collect {|package| "pkgconfig(#{package.id})"}
      end

      private
      def install_command_line(package)
        if package.start_with?("https://")
          package = resolve_package_url_template(package)
        end
        ["dnf", "install", "-y", package]
      end

      def need_super_user_priviledge?
        true
      end

      def resolve_package_url_template(package_url_template)
        os_release = OSRelease.new
        package_url_template % {
          distribution: os_release.id,
          major_version: major_version,
          version: os_release.version,
        }
      end

      def major_version
        major_version_string = File.read("/etc/redhat-release")[/(\d+)/, 0]
        Integer(major_version_string, 10)
      end
    end
  end
end
