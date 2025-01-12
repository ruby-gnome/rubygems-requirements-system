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
  SystemRepository = RubyGemsRequirementsSystem::SystemRepository

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

  def test_repository
    prefix = "system: libpq: debian:"
    gemspec_requirements = [
      "#{prefix} repository: id: pgdg",
      "#{prefix} repository: components: main",
      "#{prefix} repository: signed-by: https://www.postgresql.org/media/keys/ACCC4CF8.asc",
      "#{prefix} repository: suites: %{code_name}-pgdg",
      "#{prefix} repository: uris: https://apt.postgresql.org/pub/repos/apt",
      "#{prefix} libpq-dev",
    ]
    repository_properties = {
      "components" => "main",
      "signed-by" => "https://www.postgresql.org/media/keys/ACCC4CF8.asc",
      "suites" => "%{code_name}-pgdg",
      "uris" => "https://apt.postgresql.org/pub/repos/apt",
    }
    repository = SystemRepository.new("pgdg", repository_properties)
    assert_equal([
                   Requirement.new([Package.new("libpq")],
                                   [
                                     repository,
                                     "libpq-dev",
                                   ]),
                 ],
                 parse(gemspec_requirements))
  end

  def test_repositories
    prefix = "system: groonga: debian:"
    gemspec_requirements = [
      "#{prefix} repository: id: apache-arrow",
      "#{prefix} repository: components: main",
      "#{prefix} repository: signed-by: https://dist.apache.org/repos/dist/release/arrow/KEYS",
      "#{prefix} repository: suites: %{code_name}",
      "#{prefix} repository: uris: https://apache.jfrog.io/artifactory/arrow/%{distribution}/",
      "#{prefix} repository: id: groonga",
      "#{prefix} repository: components: main",
      "#{prefix} repository: signed-by: https://packages.groonga.org/%{distribution}/groonga-archive-keyring.asc",
      "#{prefix} repository: suites: %{code_name}",
      "#{prefix} repository: uris: https://packages.groonga.org/%{distribution}/",
      "#{prefix} libgroonga-dev",
    ]
    arrow_repository_properties = {
      "components" => "main",
      "signed-by" => "https://dist.apache.org/repos/dist/release/arrow/KEYS",
      "suites" => "%{code_name}",
      "uris" => "https://apache.jfrog.io/artifactory/arrow/%{distribution}/",
    }
    arrow_repository = SystemRepository.new("apache-arrow",
                                            arrow_repository_properties)
    groonga_repository_properties = {
      "components" => "main",
      "signed-by" => "https://packages.groonga.org/%{distribution}/groonga-archive-keyring.asc",
      "suites" => "%{code_name}",
      "uris" => "https://packages.groonga.org/%{distribution}/",
    }
    groonga_repository = SystemRepository.new("groonga",
                                              groonga_repository_properties)
    assert_equal([
                   Requirement.new([Package.new("groonga")],
                                   [
                                     arrow_repository,
                                     groonga_repository,
                                     "libgroonga-dev",
                                   ]),
                 ],
                 parse(gemspec_requirements))
  end
end
