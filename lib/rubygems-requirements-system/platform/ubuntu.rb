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

require_relative "debian"

module RubyGemsRequirementsSystem
  module Platform
    class Ubuntu < Debian
      Platform.register(self)

      class << self
        def current_platform?
          os_release = OSRelease.new
          case os_release.id
          when "ubuntu"
            return true
          else
            return true if os_release.id_like.include?("ubuntu")
          end
          false
        end
      end

      def target?(platform)
        platform == "ubuntu" || super
      end

      private
      def prepare_command_lines(package)
        if package.is_a?(String) and package.start_with?("ppa:")
          [
            ["apt-get", "update"],
            install_command_line("software-properties-common"),
          ]
        else
          super
        end
      end

      def install_command_line_package(package)
        if package.start_with?("ppa:")
          [
            "add-apt-repository",
            "-y",
            package,
          ]
        else
          super
        end
      end
    end
  end
end
