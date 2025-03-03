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

require "open-uri"
require "json"

Gem::Specification.new do |spec|
  spec.name = "dummy-postgresql-17"
  spec.version = "1.0.0"
  spec.authors = ["Sutou Kouhei"]
  spec.email = ["kou@cozmixng.org"]
  spec.licenses = ["LGPL-3.0-or-later"]
  spec.summary = "Dummy gem that uses PostgreSQL 17"
  spec.description = "This is for testing rubygems-requirements-system"
  spec.extensions = ["ext/dummy-postgresql-17/extconf.rb"]
  spec.files = ["ext/dummy-postgresql-17/extconf.rb"]

  spec.add_runtime_dependency("pkg-config")

  prefix = "system: libpq >= 17"

  spec.requirements << "#{prefix}: debian: repository: id: pgdg"
  spec.requirements << "#{prefix}: debian: repository: uris: https://apt.postgresql.org/pub/repos/apt"
  spec.requirements << "#{prefix}: debian: repository: signed-by: https://www.postgresql.org/media/keys/ACCC4CF8.asc"
  spec.requirements << "#{prefix}: debian: repository: suites: %{code_name}-pgdg"
  spec.requirements << "#{prefix}: debian: repository: components: main"

  spec.requirements << "#{prefix}: debian: libpq-dev"

  # We need to install libssl.pc explicitly because postgresql17-devel
  # doesn't have openssl-devel dependency.
  spec.requirements << "#{prefix}: rhel: pkgconfig(libssl)"

  spec.requirements << "#{prefix}: rhel: repository: id: pgdg17"
  spec.requirements << "#{prefix}: rhel: repository: name: PostgreSQL 17 $releasever - $basearch"
  spec.requirements << "#{prefix}: rhel: repository: baseurl: https://download.postgresql.org/pub/repos/yum/17/redhat/rhel-$releasever-$basearch"
  spec.requirements << "#{prefix}: rhel: repository: gpgkey: https://download.postgresql.org/pub/repos/yum/keys/PGDG-RPM-GPG-KEY-RHEL"

  spec.requirements << "#{prefix}: rhel: module: disable: postgresql"

  spec.requirements << "#{prefix}: rhel: postgresql17-devel"
end
