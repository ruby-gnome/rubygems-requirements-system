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

Bundler::Plugin::API.hook(Bundler::Plugin::Events::GEM_BEFORE_INSTALL_ALL) do |dependencies|
  Gem.pre_install do |gem_installer|
    # We use RubyGems plugin for non Bundler.
    next if gem_installer.class == Gem::Installer

    require_relative "lib/rubygems-requirements-system/installer"

    ui = Bundler.ui
    installer = RubyGemsRequirementsSystem::Installer.new(gem_installer.spec, ui)
    installer.install
  end
end
