# Copyright (C) 2017-2025  Ruby-GNOME Project Team
#
# This program is free software: you can redistribute it and/or modify
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

module RubyGemsRequirementsSystem
  module Platform
    PLATFORM_CLASSES = []

    class << self
      def register(platform_class)
        PLATFORM_CLASSES << platform_class
      end

      def detect(ui)
        PLATFORM_CLASSES.reverse_each do |platform_class|
          return platform_class.new(ui) if platform_class.current_platform?
        end
        Unknown.new(ui)
      end
    end
  end
end

require_relative "platform/base"

# macOS
require_relative "platform/macports"


# FreeBSD
require_relative "platform/freebsd"


# Linux
require_relative "platform/arch-linux"
require_relative "platform/gentoo-linux"

require_relative "platform/debian"
require_relative "platform/ubuntu"
require_relative "platform/alt-linux"

require_relative "platform/pld-linux"

require_relative "platform/fedora"
require_relative "platform/red-hat-enterprise-linux"
require_relative "platform/amazon-linux-2"
require_relative "platform/amazon-linux-2023"

require_relative "platform/suse"

require_relative "platform/alpine-linux"


# Platform independent
require_relative "platform/homebrew"
require_relative "platform/conda"
# TODO: Conan
# TODO: vcpkg

# Fallback
require_relative "platform/unknown"
