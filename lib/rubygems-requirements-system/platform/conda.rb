# Copyright (C) 2023-2025  Ruby-GNOME Project Team
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
    class Conda < Base
      Platform.register(self)

      class << self
        def current_platform?
          ENV["CONDA_PREFIX"] && ExecutableFinder.exist?("conda")
        end
      end

      def target?(platform)
        platform == "conda"
      end

      private
      def install_command_line(package)
        ["conda", "install", "-c", "conda-forge", "-y", package]
      end

      def need_super_user_priviledge?
        false
      end
    end
  end
end
