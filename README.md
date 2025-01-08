# rubygems-requirements-system

## Summary

This is a RubyGems plugin. This installs system packages that are
needed by a gem automatically.

This is convenient for both of users and developers.

Users don't need to install gem dependencies separately.

Developers don't need to write documents how to install gem
dependencies.

## Motivation

Bindings are helpful for developers because developers don't need to
re-implement existing features. But users need to install not only
bindings but also dependencies.

There are some approaches to reduce the inconvenience:

1. Installs dependencies automatically
2. Bundles dependencies (a.k.a. fat gem)

The 1. approach is used by Ruby-GNOME packages such as glib2 gem and
gtk4 gem.

The 2. approach is used by Nokogiri.

If gems that use the 2. approach are maintained actively, there are
not much problems. There are several problems otherwise. For example,
security concerns and new CRuby support.

See also:
https://slide.rabbit-shocker.org/authors/kou/rubykaigi-takeout-2020/

The 1. approach will reduce maintenance costs. It will help both of
developers and users. If we can reduce maintenance costs for
developers, developers can focus on new features and bug fixes than
releases.

## Usage

Add `rubygems-requirements-system` to your gem's runtime dependencies:

```ruby
Gem::Specification.new do |spec|
  # ...
  spec.add_runtime_dependency("rubygems-requirements-system")
  # ...
end
```

Add dependency information to `Gem::Specification#requirements`:

```ruby
Gem::Specification.new do |spec|
  # ...

  # Install GObject. Package ID is pkg-config's package name for now.
  # We'll add support for other package system's name such as CMake
  # package's name.
  # We can specify package names for each platform.
  spec.requirements << "system: gobject-2.0: alt_linux: glib2-devel"
  spec.requirements << "system: gobject-2.0: arch_linux: glib2"
  spec.requirements << "system: gobject-2.0: conda: glib"
  spec.requirements << "system: gobject-2.0: debian: libglib2.0-dev"
  spec.requirements << "system: gobject-2.0: gentoo_linux: dev-libs/glib"
  spec.requirements << "system: gobject-2.0: homebrew: glib"
  spec.requirements << "system: gobject-2.0: macports: glib2"
  # We can omit the Red Hat Enterprise Linux family case because
  # "pkgconfig(gobject-2.0)" can be generated automatically.
  spec.requirements << "system: gobject-2.0: rhel: pkgconfig(gobject-2.0)"

  # ...
end
```

You can require dependency A or B. For example, you can require
`mysqlclient` or `libmariadb`.

```ruby
Gem::Specification.new do |spec|
  # ...

  # We need mysqliclient or libmariadb for this gem.
  spec.requirements << "system: mysqlclient|libmariadb: arch_linux: mariadb-libs"
  spec.requirements << "system: mysqlclient|libmariadb: debian: libmysqlclient-dev"
  spec.requirements << "system: mysqlclient|libmariadb: debian: libmariadb-dev"

  # ...
end
```

You can install multiple packages for a dependency.

```ruby
Gem::Specification.new do |spec|
  # ...

  # We need to install multiple packages to use cairo with conda.
  spec.requirements << "system: cairo: conda: cairo"
  spec.requirements << "system: cairo: conda: expat"
  spec.requirements << "system: cairo: conda: xorg-kbproto"
  spec.requirements << "system: cairo: conda: xorg-libxau"
  spec.requirements << "system: cairo: conda: xorg-libxext"
  spec.requirements << "system: cairo: conda: xorg-libxrender"
  spec.requirements << "system: cairo: conda: xorg-renderproto"
  spec.requirements << "system: cairo: conda: xorg-xextproto"
  spec.requirements << "system: cairo: conda: xorg-xproto"
  spec.requirements << "system: cairo: conda: zlib"

  # ...
end
```

## Requirements

RubyGems 3.5.0 or later is required. RubyGems can load installed
plugin immediately since 3.5.0.

If `gem install glib2` installs rubygems-requirements-system gem as a
dependency, old RubyGems doesn't use a RubyGems plugin in
rubygems-requirements-system gem while installing glib2 gem. So glib2
gem dependencies aren't installed automatically.

## History

This is based on
[native-package-installer](https://github.com/ruby-gnome/native-package-installer)
gem. We could add support for RubyGems plugin to
native-package-installer but we didn't. Because "native" package isn't
a natural name for a package on the target platform. We want to use
other word than "native". So we create a new gem.

## License

Copyright (C) 2025  Ruby-GNOME Project Team

LGPL-3 or later. See doc/text/lgpl-3.txt for details.
