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
          not pacman_path.nil?
        end

        def pacman_path
          finder = ExecutableFinder.new("pacman")
          case RUBY_PLATFORM
          when "i386-mingw32"
            Dir.glob("c:/msys{64,32,*}/usr/bin").each do |bin|
              finder.append_path(bin)
            end
          when "x64-mingw32", "x64-mingw-ucrt", "aarch64-mingw-ucrt"
            Dir.glob("c:/msys{64,*}/usr/bin").each do |bin|
              finder.append_path(bin)
            end
          end
          finder.find
        end

        def package_prefix
          ENV["MINGW_PACKAGE_PREFIX"]
        end
      end

      def target?(platform)
        platform == "msys2"
      end

      def default_system_packages(packages)
        prefix = self.class.package_prefix
        return if prefix.nil?
        packages.collect do |package|
          "#{prefix}-#{package.id}"
        end
      end

      private
      def install_command_line(package)
        ensure_pacman_in_path
        package = "#{self.class.package_prefix}-#{package}"
        ["pacman", "-S", "--noconfirm", package]
      end

      def need_super_user_priviledge?
        false
      end

      def ensure_pacman_in_path
        pacman_path = self.class.pacman_path
        return if pacman_path.nil?
        pacman_dir = File.dirname(pacman_path)
        return if ENV["PATH"].split(File::PATH_SEPARATOR).include?(pacman_dir)
        ENV["PATH"] = [pacman_dir, ENV["PATH"]].join(File::PATH_SEPARATOR)
      end
    end
  end
end
