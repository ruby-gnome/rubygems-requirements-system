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

require_relative "base"

module RubyGemsRequirementsSystem
  module Platform
    class MSYS2 < Base
      Platform.register(self)

      class << self
        def current_platform?
          return false if Object.const_defined?(:RubyInstaller)
          return false if package_prefix.nil?
          ExecutableFinder.exist?("pacman")
        end

        def package_prefix
          ENV["MINGW_PACKAGE_PREFIX"]
        end
      end

      def target?(platform)
        platform == "msys2"
      end

      private
      def install_command_line(package)
        [
          "pacman",
          "-S",
          "--noconfirm",
          "#{self.class.package_prefix}-#{package}"
        ]
      end

      def need_super_user_priviledge?
        false
      end
    end
  end
end
