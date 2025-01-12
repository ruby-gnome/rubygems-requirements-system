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

      def valid_system_package?(package)
        return true unless package.start_with?("module:")

        action, target = parse_module_system_package(package)
        case action
        when "enable", "disable"
        else
          return false
        end
        return false if target.nil?

        true
      end

      def valid_system_repository?(repository)
        baseurl = repository["baseurl"]
        return false if baseurl.nil?
        return false if baseurl.empty?

        true
      end

      def default_system_packages(packages)
        packages.collect {|package| "pkgconfig(#{package.id})"}
      end

      private
      def parse_module_system_package(package)
        # "module: disable: postgresql" ->
        # ["module", "disable", "postgresql"]
        _, action, target = package.split(/:\s*/, 3)
        [action, target]
      end

      def install_command_line(package)
        if package.is_a?(SystemRepository)
          install_command_line_repository(package)
        elsif package.start_with?("module:")
          install_command_line_module(package)
        else
          install_command_line_package(package)
        end
      end

      def install_command_line_repository(repository)
        temporary_file_base_name = [
          "rubygems-requirements-system-fedora-#{repository.id}",
          ".repo",
        ]
        repo = create_temporary_file(temporary_file_base_name)
        repo.puts("[#{repository.id}]")
        {
          "name" => resolve_value_template(repository["name"]),
          "baseurl" => resolve_value_template(repository["baseurl"]),
          "enabled" => "1",
          "gpgcheck" => repository["gpgkey"] ? "1" : "0",
          "gpgkey" => resolve_value_template(repository["gpgkey"]),
        }.each do |key, value|
          next if value.nil?
          repo.puts("#{key}=#{value}")
        end
        repo.close
        FileUtils.chmod("go+r", repo.path)
        [
          "cp",
          repo.path,
          "/etc/yum.repos.d/#{repository.id}.repo",
        ]
      end

      def install_command_line_module(package)
        action, target = parse_module_system_package(package)
        ["dnf", "-y", "module", action, target]
      end

      def install_command_line_package(package)
        if package.start_with?("https://")
          package = resolve_value_template(package)
        end
        ["dnf", "-y", "install", package]
      end

      def need_super_user_priviledge?
        true
      end

      def resolve_value_template(template)
        return nil if template.nil?

        os_release = OSRelease.new
        template % {
          distribution: os_release.id,
          major_version: major_version.to_s,
          version: os_release.version_id,
        }
      end

      def major_version
        major_version_string = OSRelease.new.version_id.split(".")[0]
        Integer(major_version_string, 10)
      end
    end
  end
end
