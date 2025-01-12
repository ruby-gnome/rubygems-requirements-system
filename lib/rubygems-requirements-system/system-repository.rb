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
  class SystemRepository
    attr_reader :id
    attr_reader :properties
    protected :properties
    def initialize(id, properties)
      @id = id
      @properties = properties
    end

    def ==(other)
      other.is_a?(self.class) and
        @id == other.id and
        @properties == other.properties
    end

    def eql?(other)
      self == other
    end

    def hash
      [@id, @properties].hash
    end

    def [](key)
      @properties[key]
    end

    def each(&block)
      @properties.each(&block)
    end
  end
end
