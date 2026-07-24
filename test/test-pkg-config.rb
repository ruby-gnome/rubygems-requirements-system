# Copyright (C) 2026  Ruby-GNOME Project Team
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

require_relative "../lib/rubygems-requirements-system/installer"

class TestPkgConfigConda < Test::Unit::TestCase
  PackageConfig = RubyGemsRequirementsSystem::PackageConfig

  def setup
    @original_conda_exe = ENV["CONDA_EXE"]
    @original_conda_prefix = ENV["CONDA_PREFIX"]
    PackageConfig.clear_configure_args_cache
  end

  def teardown
    ENV["CONDA_EXE"] = @original_conda_exe
    ENV["CONDA_PREFIX"] = @original_conda_prefix
    PackageConfig.clear_configure_args_cache
  end

  def test_conda_exe_adds_base_lib_pkgconfig
    Dir.mktmpdir do |dir|
      conda_bin = File.join(dir, "bin")
      FileUtils.mkdir_p(conda_bin)
      lib_pkgconfig = File.join(dir, "lib", "pkgconfig")
      FileUtils.mkdir_p(lib_pkgconfig)

      ENV["CONDA_EXE"] = File.join(conda_bin, "conda")
      ENV.delete("CONDA_PREFIX")
      PackageConfig.clear_configure_args_cache

      default_path = PackageConfig.default_path
      assert_include(default_path.split(File::PATH_SEPARATOR), lib_pkgconfig)
    end
  end

  def test_conda_prefix_adds_lib_pkgconfig
    Dir.mktmpdir do |dir|
      lib_pkgconfig = File.join(dir, "lib", "pkgconfig")
      FileUtils.mkdir_p(lib_pkgconfig)

      ENV["CONDA_PREFIX"] = dir
      ENV.delete("CONDA_EXE")
      PackageConfig.clear_configure_args_cache

      default_path = PackageConfig.default_path
      assert_include(default_path.split(File::PATH_SEPARATOR), lib_pkgconfig)
    end
  end

  def test_finds_pc_file_via_conda_exe
    Dir.mktmpdir do |dir|
      conda_bin = File.join(dir, "bin")
      FileUtils.mkdir_p(conda_bin)
      lib_pkgconfig = File.join(dir, "lib", "pkgconfig")
      FileUtils.mkdir_p(lib_pkgconfig)
      File.write(File.join(lib_pkgconfig, "test-lib.pc"), <<~PC)
        prefix=#{dir}
        libdir=${prefix}/lib
        includedir=${prefix}/include

        Name: test-lib
        Description: A test library
        Version: 1.2.3
        Cflags: -I${includedir}
        Libs: -L${libdir} -ltest
      PC

      ENV["CONDA_EXE"] = File.join(conda_bin, "conda")
      ENV.delete("CONDA_PREFIX")
      PackageConfig.clear_configure_args_cache

      pkg = PackageConfig.new("test-lib")
      assert_true(pkg.exist?)
      assert_equal("1.2.3", pkg.version)
    end
  end
end
