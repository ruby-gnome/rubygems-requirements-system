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

require_relative "red-hat-enterprise-linux"

module RubyGemsRequirementsSystem
  module Platform
    class Fedora < RedHatEnterpriseLinux
      Platform.register(self)

      class << self
        def current_platform?
          os_release = OSRelease.new
          os_release.id == "fedora" or os_release.id_like.include?("fedora")
        end
      end

      def target?(platform)
        platform == "fedora" || super
      end

      private
      def install_command_line(package)
        ["dnf", "install", "-y", package]
      end

      def need_super_user_priviledge?
        true
      end
    end
  end
end
