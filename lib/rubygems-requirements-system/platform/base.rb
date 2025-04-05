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

require "fileutils"
require "open-uri"
require "tempfile"

require_relative "../executable-finder"
require_relative "../os-release"

module RubyGemsRequirementsSystem
  module Platform
    class Base
      def initialize(ui)
        @ui = ui
      end

      def target?(platform)
        raise NotImpelementedError
      end

      def default_system_packages(packages)
        nil
      end

      def valid_system_package?(package)
        true
      end

      def valid_system_repository?(repository)
        false
      end

      def install(requirement)
        synchronize do
          requirement.system_packages.any? do |package|
            install_package(package) and requirement.satisfied?
          end
        end
      end

      private
      def sudo
        if have_priviledge?
          nil
        else
          @sudo ||= ExecutableFinder.find("sudo")
        end
      end

      def synchronize
        if Gem.respond_to?(:state_home)
          state_home = Gem.state_home
        else
          state_home =
            ENV["XDG_STATE_HOME"] ||
            File.join(Gem.user_home, ".local", "state")
        end
        lock_file_path = File.join(state_home,
                                   "gem",
                                   "requirements_system_lock")
        FileUtils.mkdir_p(File.dirname(lock_file_path))
        File.open(lock_file_path, "w") do |lock_file|
          lock_file.flock(File::LOCK_EX)
          yield
        end
      end

      def super_user?
        Process.uid.zero?
      end

      def need_super_user_priviledge?
        raise NotImpelementedError
      end

      def have_priviledge?
        return true unless need_super_user_priviledge?
        super_user?
      end

      def temporary_file_scope
        @temporary_files = []
        begin
          yield
        ensure
          @temporary_files.each(&:close!)
        end
      end

      def create_temporary_file(basename)
        file = Tempfile.new(basename)
        @temporary_files << file
        file
      end

      def install_package(package)
        temporary_file_scope do
          prepare_command_lines(package).each do |command_line|
            unless run_command_line(package, "prepare", command_line)
              return false
            end
          end
          run_command_line(package, "install", install_command_line(package))
        end
      end

      def run_command_line(package, action, command_line)
        if package.is_a?(SystemRepository)
          package_label = "repository(#{package.id})"
        else
          package_label = package
        end
        prefix = "#{package_label}: #{action}"
        @ui.info("#{prefix}: Start")
        failed_to_get_super_user_priviledge = false
        if have_priviledge?
          succeeded = system(*command_line)
        else
          if sudo
            prompt = "[sudo] password for %u to #{action} <#{package_label}>: "
            command_line = [sudo, "-p", prompt, *command_line]
            succeeded = system(*command_line)
          else
            succeeded = false
            failed_to_get_super_user_priviledge = true
          end
        end
        if failed_to_get_super_user_priviledge
          result_message = "require super user privilege"
        else
          result_message = succeeded ? "succeeded" : "failed"
        end
        @ui.info("#{prefix}: #{result_message}")

        unless succeeded
          escaped_command_line = command_line.collect do |part|
            Shellwobrds.escape(part)
          end
          @ui.error("#{prefix}: Failed.")
          @ui.error("Run the following command " +
                    "to #{action} required system package: " +
                    escaped_command_line.join(" "))
        end
        succeeded
      end

      def prepare_command_lines(package)
        []
      end

      def install_command_line(package)
        raise NotImpelementedError
      end
    end
  end
end
