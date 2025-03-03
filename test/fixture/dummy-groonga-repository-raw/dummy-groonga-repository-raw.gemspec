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
  spec.name = "dummy-groonga"
  spec.version = "1.0.0"
  spec.authors = ["Sutou Kouhei"]
  spec.email = ["kou@cozmixng.org"]
  spec.licenses = ["LGPL-3.0-or-later"]
  spec.summary = "Dummy gem that uses Groonga with raw repository"
  spec.description = "This is for testing rubygems-requirements-system"
  spec.extensions = ["ext/dummy-groonga-repository-raw/extconf.rb"]
  spec.files = ["ext/dummy-groonga-repository-raw/extconf.rb"]

  spec.add_runtime_dependency("pkg-config")

  spec.requirements << "system: groonga: debian: repository: id: apache-arrow"
  spec.requirements << "system: groonga: debian: repository: uris: https://apache.jfrog.io/artifactory/arrow/%{distribution}/"
  spec.requirements << "system: groonga: debian: repository: signed-by: https://downloads.apache.org/arrow/KEYS"

  spec.requirements << "system: groonga: debian: repository: id: groonga"
  spec.requirements << "system: groonga: debian: repository: uris: https://packages.groonga.org/%{distribution}/"
  spec.requirements << "system: groonga: debian: repository: signed-by: https://packages.groonga.org/%{distribution}/groonga-archive-keyring.asc"

  spec.requirements << "system: groonga: debian: libgroonga-dev"

  spec.requirements << "system: groonga: rhel: repository: id: apache-arrow"
  spec.requirements << "system: groonga: rhel: repository: baseurl: https://apache.jfrog.io/artifactory/arrow/almalinux/$releasever/$basearch/"
  spec.requirements << "system: groonga: rhel: repository: gpgkey: https://downloads.apache.org/arrow/KEYS"

  spec.requirements << "system: groonga: rhel: repository: id: groonga"
  spec.requirements << "system: groonga: rhel: repository: baseurl: https://packages.groonga.org/almalinux/$releasever/$basearch/"
  spec.requirements << "system: groonga: rhel: repository: gpgkey: https://packages.groonga.org/almalinux/groonga-release-keyring.asc"

  spec.requirements << "system: groonga: rhel: groonga-devel"
end
