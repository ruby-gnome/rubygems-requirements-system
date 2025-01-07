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

require_relative "base"

module RubyGemsRequirementsSystem
  module Platform
    class RedHatEnterpriseLinux < Base
      Platform.register(self)

      class << self
        def current_platform?
          os_release = OSRelease.new
          os_release.id_like.include?("rhel")
        end
      end

      def target?(platform)
        case platform
        when "rhel"
          true
        when "redhat" # For backward compatibility
          true
        else
          false
        end
      end

      def default_system_packages(packages)
        packages.collect {|package| "pkgconfig(#{package.id})"}
      end

      private

      def install_command_line(package)
        if major_version >= 9
          ["dnf", "install", "--enablerepo=crb", "-y", package]
        elsif major_version >= 8
          ["dnf", "install", "--enablerepo=powertools", "-y", package]
        else
          ["yum", "install", "-y", package]
        end
      end

      def need_super_user_priviledge?
        true
      end

      def major_version
        major_version_string = File.read("/etc/redhat-release")[/(\d+)/, 0]
        Integer(major_version_string, 10)
      end
    end
  end
end
