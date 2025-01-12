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

module RubyGemsRequirementsSystem
  class OSRelease
    include Enumerable

    def initialize
      parse
    end

    def each(&block)
      @variables.each(&block)
    end

    def [](key)
      @variables[key]
    end

    def id
      self["ID"]
    end

    def id_like
      (self["ID_LIKE"] || "").split(/\s+/)
    end

    def version
      self["VERSION"]
    end

    def version_codename
      self["VERSION_CODENAME"]
    end

    def version_id
      self["VERSION_ID"]
    end

    private
    def parse
      @variables = {}
      path = "/etc/os-release"
      return unless File.exist?(path)
      File.foreach(path) do |line|
        key, value = line.strip.split("=", 2)
        next if value.nil?
        if value.start_with?("\"") and value.end_with?("\"")
          value = value[1..-2]
        end
        @variables[key] = value
      end
    end
  end
end
