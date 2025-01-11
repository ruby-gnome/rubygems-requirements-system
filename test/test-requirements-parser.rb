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

require_relative "helper"

class TestRequiremtsParser < Test::Unit::TestCase
  Package = RubyGemsRequirementsSystem::Package
  Platform = RubyGemsRequirementsSystem::Platform
  Requirement = RubyGemsRequirementsSystem::Requirement
  RequirementsParser = RubyGemsRequirementsSystem::RequirementsParser

  def setup
    @platform = Platform::Ubuntu.new
  end

  def parse(gemspec_requirements)
    RequirementsParser.new(gemspec_requirements, @platform).parse
  end

  def test_minimal
    gemspec_requirements = [
      "system: cairo: debian: libcairo2-dev",
    ]
    assert_equal([
                   Requirement.new([Package.new("cairo")],
                                   ["libcairo2-dev"]),
                 ],
                 parse(gemspec_requirements))
  end

  def test_required_version
    gemspec_requirements = [
      "system: cairo >= 1.2.0: debian: libcairo2-dev",
    ]
    assert_equal([
                   Requirement.new([Package.new("cairo", ">=", "1.2.0")],
                                   ["libcairo2-dev"]),
                 ],
                 parse(gemspec_requirements))
  end

  def test_or_dependency
    gemspec_requirements = [
      "system: mysqlclient|libmariadb: debian: libmariadb-dev",
      "system: mysqlclient|libmariadb: ubuntu: libmysqlclient-dev",
    ]
    assert_equal([
                   Requirement.new([
                                     Package.new("mysqlclient"),
                                     Package.new("libmariadb"),
                                   ],
                                   [
                                     "libmariadb-dev",
                                     "libmysqlclient-dev",
                                   ]),
                 ],
                 parse(gemspec_requirements))
  end

  def test_https
    deb_url = "https://packages.groonga.org/%{distribution}/groonga-apt-source-latest-%{code_name}.deb"
    gemspec_requirements = [
      "system: groonga: debian: #{deb_url}",
    ]
    assert_equal([
                   Requirement.new([Package.new("groonga")],
                                   [deb_url]),
                 ],
                 parse(gemspec_requirements))
  end

  def test_ppa
    gemspec_requirements = [
      "system: groonga: ubuntu: ppa:groonga/ppa",
    ]
    assert_equal([
                   Requirement.new([Package.new("groonga")],
                                   ["ppa:groonga/ppa"]),
                 ],
                 parse(gemspec_requirements))
  end
end
