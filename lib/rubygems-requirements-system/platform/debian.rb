# Copyright (C) 2013-2025  Ruby-GNOME Project Team
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
    class Debian < Base
      Platform.register(self)

      class << self
        def current_platform?
          os_release = OSRelease.new
          case os_release.id
          when "debian", "raspbian"
            return true
          else
            return true if os_release.id_like.include?("debian")
          end
          false
        end
      end

      def target?(platform)
        case platform
        when "debian", "raspbian"
          true
        else
          false
        end
      end

      private
      def prepare_command_lines(package)
        [
          ["apt-get", "update"],
        ]
      end

      def install_command_line(package)
        if package.start_with?("https://")
          package_url = resolve_package_url_template(package)
          temporary_file_base_name = [
            "rubygems-requirements-system-debian",
            File.extname(package),
          ]
          local_package = create_temporary_file(temporary_file_base_name)
          URI.open(package_url) do |response|
            IO.copy_stream(response, local_package)
          end
          local_package.close
          @temporary_files << local_package
          FileUtils.chmod("go+r", local_package.path)
          package = local_package.path
        end
        [
          "env",
          "DEBIAN_FRONTEND=noninteractive",
          "apt-get",
          "install",
          "-V",
          "-y",
          package,
        ]
      end

      def need_super_user_priviledge?
        true
      end

      def resolve_package_url_template(package_url_template)
        os_release = OSRelease.new
        package_url_template % {
          distribution: os_release.id,
          code_name: os_release.version_codename,
          version: os_release.version_id,
        }
      end
    end
  end
end
