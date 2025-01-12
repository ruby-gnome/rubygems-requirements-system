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

require_relative "fedora"

module RubyGemsRequirementsSystem
  module Platform
    class RedHatEnterpriseLinux < Fedora
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
          super
        end
      end

      private
      def install_command_line_package(package)
        if package.start_with?("https://")
          package = resolve_package_url_template(package)
        end
        if major_version >= 9
          ["dnf", "-y", "install", "--enablerepo=crb", package]
        elsif major_version >= 8
          ["dnf", "-y", "install", "--enablerepo=powertools", package]
        else
          ["yum", "-y", "install", package]
        end
      end

      def need_super_user_priviledge?
        true
      end
    end
  end
end
