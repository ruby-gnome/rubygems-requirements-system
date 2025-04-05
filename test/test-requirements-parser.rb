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
  Executable = RubyGemsRequirementsSystem::Executable
  Package = RubyGemsRequirementsSystem::Package
  Platform = RubyGemsRequirementsSystem::Platform
  Requirement = RubyGemsRequirementsSystem::Requirement
  RequirementsParser = RubyGemsRequirementsSystem::RequirementsParser
  SystemRepository = RubyGemsRequirementsSystem::SystemRepository
  UI = RubyGemsRequirementsSystem::UI

  def setup
    @ui = UI.new(Gem::SilentUI.new)
    @platform = Platform::Ubuntu.new(@ui)
  end

  def parser(gemspec_requirements)
    RequirementsParser.new(gemspec_requirements, @platform, @ui)
  end

  def parse(gemspec_requirements)
    parser(gemspec_requirements).parse
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

  def test_executable
    assert_equal([
                   Requirement.new([Executable.new("dot")],
                                   ["graphviz"]),
                 ],
                 parse(["system: executable(dot): debian: graphviz"]))
  end

  def test_pkgconfig
    assert_equal([
                   Requirement.new([Package.new("cairo")],
                                   ["libcairo2-dev"]),
                 ],
                 parse(["system: pkgconfig(cairo): debian: libcairo2-dev"]))
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

  sub_test_case("#parse_dependency") do
    def parse_dependency(type, value, raw_dependency)
      parser([]).__send__(:parse_dependency, type, value, raw_dependency)
    end

    sub_test_case("pkgconfig") do
      def parse_dependency(value)
        super("pkgconfig", value, value)
      end

      def test_id
        assert_equal(Package.new("cairo"),
                     parse_dependency("cairo"))
      end

      def test_operator_equal
        assert_equal(Package.new("cairo", "==", "1.0"),
                     parse_dependency("cairo == 1.0"))
      end

      def test_operator_greater_than_equal
        assert_equal(Package.new("cairo", ">=", "1.0"),
                     parse_dependency("cairo >= 1.0"))
      end

      def test_operator_greater_than
        assert_equal(Package.new("cairo", ">", "1.0"),
                     parse_dependency("cairo > 1.0"))
      end

      def test_operator_less_than_equal
        assert_equal(Package.new("cairo", "<=", "1.0"),
                     parse_dependency("cairo <= 1.0"))
      end

      def test_operator_less_than
        assert_equal(Package.new("cairo", "<", "1.0"),
                     parse_dependency("cairo < 1.0"))
      end
    end

    sub_test_case("executable") do
      def parse_dependency(value)
        super("executable", value, value)
      end

      def test_name
        assert_equal(Executable.new("dot"),
                     parse_dependency("dot"))
      end
    end
  end
end
