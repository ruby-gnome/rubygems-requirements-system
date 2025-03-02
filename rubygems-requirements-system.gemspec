# Copyright (C) 2025  Ruby-GNOME Project Team
#
# This library is free software: you can redistribute it and/or modify
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

require_relative "lib/rubygems-requirements-system/version"

Gem::Specification.new do |spec|
  spec.name = "rubygems-requirements-system"
  spec.version = RubyGemsRequirementsSystem::VERSION
  spec.authors = ["Sutou Kouhei"]
  spec.email = ["kou@clear-code.com"]
  spec.summary = "Users can install system packages automatically on \"gem install\""
  spec.description = <<-DESCRIPTION.strip
Users need to install system packages to install an extension library
that depends on system packages. It bothers users because users need to
install system packages and an extension library separately.

rubygems-requirements-system helps to install system packages on "gem install".
Users can install both system packages and an extension library by one action,
"gem install".
  DESCRIPTION
  spec.homepage = "https://github.com/ruby-gnome/rubygems-requirements-system"
  spec.licenses = ["LGPL-3.0-or-later"]
  spec.require_paths = ["lib"]

  spec.files = ["README.md", "Rakefile"]
  spec.files += Dir.glob("lib/**/*.rb")
  spec.files += Dir.glob("doc/text/**/*.*")
end
