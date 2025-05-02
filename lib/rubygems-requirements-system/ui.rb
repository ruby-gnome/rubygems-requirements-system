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

module RubyGemsRequirementsSystem
  class UI
    def initialize(ui)
      @ui = ui
    end

    def debug(message)
      log(:debug, message)
    end

    def info(message)
      log(:info, message)
    end

    def warn(message)
      log(:warn, message)
    end

    def error(message)
      log(:error, message)
    end

    private
    def log(level, message)
      message = "requirements: system: #{message}"
      candidates = [level]
      case level
      when :info
        candidates << :alert # For Gem::UserInteraction
      when :warn
        candidates << :alert_warning # For Gem::UserInteraction
      when :error
        candidates << :alert_error # For Gem::UserInteraction
      end
      candidates.each do |candidate|
        if @ui.respond_to?(candidate)
          @ui.__send__(candidate, message)
          return
        end
      end
      @ui.say(message) # fallback
    end
  end
end
