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

FROM alpine

RUN \
  apk update && apk upgrade && \
  apk add \
    bash \
    build-base \
    gcc \
    make \
    ruby \
    ruby-dev \
    openssl \
    openssl-dev \
    zlib \
    zlib-dev \
    sudo \
    which

RUN \
  gem install --no-user-install \
    bundler \
    rake

RUN \
  adduser devel -G wheel -D -h /home/devel

RUN \
  echo "devel ALL=(ALL:ALL) NOPASSWD:ALL" | \
    EDITOR=tee visudo -f /etc/sudoers.d/devel

USER devel
WORKDIR /home/devel
