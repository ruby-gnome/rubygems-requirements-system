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

require_relative "../executable-finder"
require_relative "../os-release"

module RubyGemsRequirementsSystem
  module Platform
    class Base
      include Gem::UserInteraction

      def target?(platform)
        raise NotImpelementedError
      end

      def default_system_packages(packages)
        nil
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

      def install_package(package)
        command_line = prepare_command_line(package)
        if command_line
          unless run_command_line(package, "prepare", command_line)
            return false
          end
        end
        run_command_line(package, "install", install_command_line(package))
      end

      def run_command_line(package, action, command_line)
        failed_to_get_super_user_priviledge = false
        command_line = install_command_line(package)
        if have_priviledge?
          succeeded = system(*command_line)
        else
          if sudo
            prompt = "[sudo] password for %u to #{action} <#{package}>: "
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
        say("#{action.capitalize} '#{package}' system package: #{result_message}")

        unless succeeded
          escaped_command_line = command_line.collect do |part|
            Shellwords.escape(part)
          end
          alert_warning("'#{package}' system package is required.")
          alert_warning("Run the following command " +
                        "to #{action} required system package: " +
                        escaped_command.join(" "))
        end
        succeeded
      end

      def prepare_command_line(package)
        nil
      end

      def install_command_line(package)
        raise NotImpelementedError
      end
    end
  end
end
