# -*- ruby -*-
#
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

Gem::Specification.new do |spec|
  spec.name = "dummy-cairo"
  spec.version = "1.0.0"
  spec.authors = ["Sutou Kouhei"]
  spec.email = ["kou@cozmixng.org"]
  spec.licenses = ["LGPL-3.0+"]
  spec.summary = "Dummy gem that uses cairo"
  spec.description = "This is for testing rubygems-requirements-system"
  spec.extensions = ["ext/dummy-cairo/extconf.rb"]
  spec.files = ["ext/dummy-cairo/extconf.rb"]

  spec.add_runtime_dependency("rubygems-requirements-system")

  spec.requirements << "system: cairo >= 1.2.0: alpine_linux: cairo-dev"
  spec.requirements << "system: cairo >= 1.2.0: alt_linux: bzlib-devel"
  spec.requirements << "system: cairo >= 1.2.0: alt_linux: libXdmcp-devel"
  spec.requirements << "system: cairo >= 1.2.0: alt_linux: libbrotli-devel"
  spec.requirements << "system: cairo >= 1.2.0: alt_linux: libcairo-devel"
  spec.requirements << "system: cairo >= 1.2.0: alt_linux: libexpat-devel"
  spec.requirements << "system: cairo >= 1.2.0: alt_linux: libpixman-devel"
  spec.requirements << "system: cairo >= 1.2.0: arch_linux: cairo"
  spec.requirements << "system: cairo >= 1.2.0: conda: cairo"
  spec.requirements << "system: cairo >= 1.2.0: conda: expat"
  spec.requirements << "system: cairo >= 1.2.0: conda: xorg-kbproto"
  spec.requirements << "system: cairo >= 1.2.0: conda: xorg-libxau"
  spec.requirements << "system: cairo >= 1.2.0: conda: xorg-libxext"
  spec.requirements << "system: cairo >= 1.2.0: conda: xorg-libxrender"
  spec.requirements << "system: cairo >= 1.2.0: conda: xorg-renderproto"
  spec.requirements << "system: cairo >= 1.2.0: conda: xorg-xextproto"
  spec.requirements << "system: cairo >= 1.2.0: conda: xorg-xproto"
  spec.requirements << "system: cairo >= 1.2.0: conda: zlib"
  spec.requirements << "system: cairo >= 1.2.0: debian: libcairo2-dev"
  spec.requirements << "system: cairo >= 1.2.0: gentoo_linux: cairo"
  spec.requirements << "system: cairo >= 1.2.0: homebrew: cairo"
  spec.requirements << "system: cairo >= 1.2.0: macports: cairo"
  spec.requirements << "system: cairo >= 1.2.0: rhel: cairo-devel"
end
