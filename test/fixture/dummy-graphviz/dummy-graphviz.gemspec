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
  spec.name = "dummy-graphviz"
  spec.version = "1.0.0"
  spec.authors = ["Sutou Kouhei"]
  spec.email = ["kou@cozmixng.org"]
  spec.licenses = ["LGPL-3.0-or-later"]
  spec.summary = "Dummy gem that uses Graphviz"
  spec.description = "This is for testing rubygems-requirements-system"
  spec.files = ["lib/dummy-graphviz.rb"]

  spec.requirements << "system: executable(dot): alpine_linux: graphviz"
  spec.requirements << "system: executable(dot): alt_linux: graphviz"
  spec.requirements << "system: executable(dot): arch_linux: graphviz"
  spec.requirements << "system: executable(dot): conda: graphviz"
  spec.requirements << "system: executable(dot): debian: graphviz"
  spec.requirements << "system: executable(dot): fedora: graphviz"
  spec.requirements << "system: executable(dot): gentoo_linux: media-gfx/graphviz"
  spec.requirements << "system: executable(dot): homebrew: graphviz"
  spec.requirements << "system: executable(dot): macports: graphviz"
  spec.requirements << "system: executable(dot): pld_linux: graphviz"
  spec.requirements << "system: executable(dot): suse: graphviz"
end
