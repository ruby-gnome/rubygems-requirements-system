#!/bin/bash -l
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

set -eux

rm -rf build
cp -r /host build
cd build

if ruby --help | grep gems | grep -q 'default: disabled'; then
  # PLD Linux
  export RUBYOPT="--enable=gems"
fi

if gem env | grep -q -- --user-install; then
  # Arch Linux
  rake install
elif gem env | grep -q -- --install-dir; then
  # Gentoo Linux
  rake install
elif sudo which rake; then
  sudo rake install
else
  rake install
fi

test_gems=()
if [ $# -eq 0 ]; then
  for test_gem in test/fixture/*; do
    test_gems+=(${test_gem})
  done
else
  for test_gem in "$@"; do
    test_gems+=(test/fixture/${test_gem})
  done
fi
for test_gem in "${test_gems[@]}"; do
  pushd ${test_gem}
  gem build *.gemspec
  # Gentoo Linux uses --install-dir by default. It's conflicted with
  # --user-install.
  if gem env | grep -q -- --install-dir; then
    gem install ./*.gem
  else
    gem install --user-install ./*.gem
  fi
  popd
done
