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

class TestPackage < Test::Unit::TestCase
  Package = RubyGemsRequirementsSystem::Package

  sub_test_case("#satisfied?") do
    def test_no_required_version
      assert do
        Package.new("cairo").satisfied?("1.0.0")
      end
    end

    def test_equal_true
      assert do
        Package.new("cairo", "==", "1.0.0").satisfied?("1.0.0")
      end
    end

    def test_equal_false
      assert do
        not Package.new("cairo", "==", "1.0.0").satisfied?("1.0.1")
      end
    end

    def test_greater_than_equal_true
      assert do
        Package.new("cairo", ">=", "1.0.2").satisfied?("1.0.2")
      end
    end

    def test_greater_than_equal_false
      assert do
        not Package.new("cairo", ">=", "1.0.2").satisfied?("1.0.1")
      end
    end

    def test_greater_than_true
      assert do
        Package.new("cairo", ">", "1.0.2").satisfied?("1.0.3")
      end
    end

    def test_greater_than_false
      assert do
        not Package.new("cairo", ">", "1.0.2").satisfied?("1.0.2")
      end
    end

    def test_less_than_equal_true
      assert do
        Package.new("cairo", "<=", "1.0.2").satisfied?("1.0.2")
      end
    end

    def test_less_than_equal_false
      assert do
        not Package.new("cairo", "<=", "1.0.2").satisfied?("1.0.3")
      end
    end

    def test_less_than_true
      assert do
        Package.new("cairo", "<", "1.0.2").satisfied?("1.0.1")
      end
    end

    def test_less_than_false
      assert do
        not Package.new("cairo", "<", "1.0.2").satisfied?("1.0.2")
      end
    end
  end
end
