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

set -eu

group_begin() {
  echo "::group::$1"
  set -x
}

group_end() {
  set +x
  echo "::endgroup::"
}

group_begin "Prepare"
rm -rf build
cp -r /host build
cd build

if ruby --help | grep gems | grep -q 'default: disabled'; then
  # PLD Linux
  export RUBYOPT="--enable=gems"
fi
gem_install_options=()
# Gentoo Linux uses --install-dir by default. It's conflicted with
# --user-install.
if gem env | grep -q -- --install-dir; then
  :
else
  gem_install_options+=(--user-install)
fi
disable_gemrc=$(pwd)/disabled-gemrc
cat <<GEMRC > ${disable_gemrc}
requirements_system:
  enabled: false
GEMRC
group_end

group_begin "Install"
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
group_end

group_begin "Collect test targets"
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
group_end

for test_gem in "${test_gems[@]}"; do
  pushd ${test_gem}
  group_begin "Test: $(basename ${test_gem}): Prepare"
  gem build *.gemspec
  group_end
  # Must be failed
  for disabled_value in 0 no NO false FALSE; do
    group_begin "Test: $(basename ${test_gem}): Disable by env: ${disabled_value}"
    if RUBYGEMS_REQUIREMENTS_SYSTEM=${disabled_value} \
         gem install "${gem_install_options[@]}" ./*.gem; then
      exit 1
    fi
    group_end
  done
  group_begin "Test: $(basename ${test_gem}): Disable by configuration"
  # Must be failed
  if gem install "${gem_install_options[@]}" \
       --config-file=${disable_gemrc} ./*.gem; then
    exit 1
  fi
  group_end
  group_begin "Test: $(basename ${test_gem}): Default"
  # Must be succeeded
  gem install "${gem_install_options[@]}" ./*.gem
  group_end
  popd
done
