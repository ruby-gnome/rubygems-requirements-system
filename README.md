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

### Basic usage

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

### OR dependency

You can require dependency A or B. For example, you can require
`mysqlclient` or `libmariadb`.

```ruby
Gem::Specification.new do |spec|
  # ...

  # We need mysqliclient or libmariadb for this gem.

  # Try libmysqlclient-dev and then libmariadb-dev on Ubuntu. Because
  # "debian: libmariadb-dev" is also used on Ubuntu.
  #
  # mysqlclient or libmariadb will be satsfied by a system package.
  spec.requirements << "system: mysqlclient|libmariadb: ubuntu: libmysqlclient-dev"
  # Try only libmariadb-dev on Debian.
  #
  # libmariadb will be satsfied by a system package.
  spec.requirements << "system: mysqlclient|libmariadb: debian: libmariadb-dev"

  # ...
end
```

### Multiple packages per dependency

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

### Install packages via HTTPS

You can install `.deb`/`.rpm` via HTTPS. If a product provides its
APT/Yum repository configurations by `.deb`/`.rpm`, you can use this
feature to register additional APT/Yum repositories.

You can use placeholder for URL with `%{KEY}` format.

Here are available placeholders:

`debian` family platforms:

* `distribution`: The `ID` value in `/etc/os-release`. It's `debian`,
  `ubuntu` and so on.
* `code_name`: The `VERSION_CODENAME` value in `/etc/os-release`. It's
  `bookworm`, `noble` and so on.
* `version`: The `VERSION_ID` value in `/etc/os-release`. It's `12`,
  `24.04` and so on.

`fedora` family platforms:

* `distribution`: The `ID` value in `/etc/os-release`. It's `fedora`,
  `rhel`, `almalinux` and so on.
* `major_version`: The major part of `VERSION_ID` value in
  `/etc/os-release`. It's `41`, `9` and so on.
* `version`: The `VERSION_ID` value in `/etc/os-release`. It's `41`,
  `9.5` and so on.

Here is an example that uses this feature for adding new repositories:

```ruby
Gem::Specification.new do |spec|
  # ...

  # Install Groonga's APT repository for libgroonga-dev on Debian
  # family platforms.
  #
  # %{distribution} and %{code_name} are placeholders.
  #
  # On Debian GNU/Linux bookworm:
  #   https://packages.groonga.org/%{distribution}/groonga-apt-source-latest-%{code_name}.deb ->
  #   https://packages.groonga.org/debian/groonga-apt-source-latest-bookworm.deb
  #
  # On Ubuntu 24.04:
  #   https://packages.groonga.org/%{distribution}/groonga-apt-source-latest-%{code_name}.deb ->
  #   https://packages.groonga.org/ubuntu/groonga-apt-source-latest-nobole.deb
  spec.requirements << "system: groonga: debian: https://packages.groonga.org/%{distribution}/groonga-apt-source-latest-%{code_name}.deb"
  # Install libgroonga-dev from the registered repository.
  spec.requirements << "system: groonga: debian: libgroonga-dev"

  # Install 2 repositories for pkgconfig(groonga) package on RHEL
  # family plaforms:
  # 1. Apache Arrow: https://apache.jfrog.io/artifactory/arrow/almalinux/%{major_version}/apache-arrow-release-latest.rpm
  # 2. Groonga: https://packages.groonga.org/almalinux/%{major_version}/groonga-release-latest.noarch.rpm
  #
  # %{major_version} is placeholder.
  #
  # On AlmaLinux 8:
  #   https://apache.jfrog.io/artifactory/arrow/almalinux/%{major_version}/apache-arrow-release-latest.rpm ->
  #   https://apache.jfrog.io/artifactory/arrow/almalinux/8/apache-arrow-release-latest.rpm
  #
  #   https://packages.groonga.org/almalinux/%{major_version}/groonga-release-latest.noarch.rpm ->
  #   https://packages.groonga.org/almalinux/8/groonga-release-latest.noarch.rpm
  #
  # On AlmaLinux 9:
  #   https://apache.jfrog.io/artifactory/arrow/almalinux/%{major_version}/apache-arrow-release-latest.rpm ->
  #   https://apache.jfrog.io/artifactory/arrow/almalinux/9/apache-arrow-release-latest.rpm
  #
  #   https://packages.groonga.org/almalinux/%{major_version}/groonga-release-latest.noarch.rpm ->
  #   https://packages.groonga.org/almalinux/9/groonga-release-latest.noarch.rpm
  spec.requirements << "system: groonga: rhel: https://apache.jfrog.io/artifactory/arrow/almalinux/%{major_version}/apache-arrow-release-latest.rpm"
  spec.requirements << "system: groonga: rhel: https://packages.groonga.org/almalinux/%{major_version}/groonga-release-latest.noarch.rpm"
  # Install pkgconfig(groonga) from the registered repositories.
  spec.requirements << "system: groonga: rhel: pkgconfig(groonga)"

  # ...
end
```

## Configurations

### Opt-out

If you don't like that gems may install system packages automatically,
you can disable this feature by the followings:

1. Set `RUBYGEMS_REQUIREMENTS_SYSTEM=false`
2. Add the following configuration to `~/.gemrc`:

   ```yaml
   requirements_system:
     enabled: true
   ```

## Requirements

RubyGems 3.4.14 or later is required. RubyGems can load installed
plugin immediately since 3.4.14. Ruby 3.2.3 or later ships RubyGems
3.4.14 or later.

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
