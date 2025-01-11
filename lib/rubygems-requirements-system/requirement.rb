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
  Requirement = Struct.new(:packages, :system_packages) do
    def satisfied?
      packages.any? do |package|
        installed?(package)
      end
    end

    private
    def installed?(package)
      package_config = PKGConfig.package_config(package.id)
      begin
        package_config.cflags
      rescue PackageConfig::NotFoundError
        return false
      end

      package.satisfied?(package_config.version)
    end
  end
end