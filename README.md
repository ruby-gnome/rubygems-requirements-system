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

## Usage for users

If you're using Bundler, add the following line to your `Gemfile`:

```ruby
plugin "rubygems-requirements-system"
```

If you're not using Bundler, install `rubygems-requirements-system`:

```bash
gem install rubygems-requirements-system
```

## Usage for developers

Add dependency information to `Gem::Specification#requirements`.

### Basic usage

In most cases, you can just specify the followings:

1. Package ID as dependency
2. Platform ID
3. Package name on the platform

See the following example:

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
  #   https://packages.groonga.org/ubuntu/groonga-apt-source-latest-noble.deb
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

### Install repositories

You can install APT/Yum repositories by specifying metadata.

You need to specify multiple metadata for one repository. So you need
to use multiple `spec.requirements` for one repository. Here is the
syntax for one repository:

```ruby
spec.requirements << "system: #{package}: #{platform}: repository: #{key1}: #{value1}"
spec.requirements << "system: #{package}: #{platform}: repository: #{key2}: #{value2}"
# ...
```

You must specify at least `id` as `key`. For example:

```
spec.requirements << "system: libpq: debian: repository: id: pgdg"
```

You can start another repository metadata by starting `id` metadata
for another repository:

```ruby
spec.requirements << "system: #{package}: #{platform}: repository: id: repository1"
spec.requirements << "system: #{package}: #{platform}: repository: #{key1_1}: #{value1_1}"
spec.requirements << "system: #{package}: #{platform}: repository: #{key1_2}: #{value1_2}"
# ...
spec.requirements << "system: #{package}: #{platform}: repository: id: repository2"
spec.requirements << "system: #{package}: #{platform}: repository: #{key2_1}: #{value2_1}"
spec.requirements << "system: #{package}: #{platform}: repository: #{key2_2}: #{value2_2}"
# ...
```

Here are metadata for a APT repository:

* `compoennts`: Optional. The default is `main`.
* `signed-by`: Optional. The URL of armored keyring that is used for
  signing this repository.
* `suites`: Optional. The default is `%{code_name}`.
* `types`: Optional. The default is `deb`.
* `uris`: Required. The URLs that provide this repository.

See also: https://wiki.debian.org/SourcesList

Here are metadata for a Yum repository:

* `baseurl`: Required. The base URL that provides this repository.
* `gpgkey`: Optional. The URL of GPG key that is used for signing this
  repository.
* `name`: Optional. The name of this repository.

See also: TODO: Is there any URL that describes the specification of
`.repo` file?

You can use placeholder for metadata values with `%{KEY}` format.

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

Here is an example that uses this feature for adding a new repository:

```ruby
Gem::Specification.new do |spec|
  # ...

  # Install PostgreSQL's APT repository on Debian family platforms.
  #
  # %{code_name} is placeholders.
  #
  # On Debian GNU/Linux bookworm:
  #   %{code_name}-pgdg ->
  #   bookworm-pgdg
  #
  # On Ubuntu 24.04:
  #   %{code_name}-pgdg ->
  #   noble-pgdg
  spec.requirements << "system: libpq: debian: repository: id: pgdg"
  spec.requirements << "system: libpq: debian: repository: uris: https://apt.postgresql.org/pub/repos/apt"
  spec.requirements << "system: libpq: debian: repository: signed-by: https://www.postgresql.org/media/keys/ACCC4CF8.asc"
  spec.requirements << "system: libpq: debian: repository: suites: %{code_name}-pgdg"
  spec.requirements << "system: libpq: debian: repository: components: main"
  # Install libpq-dev from the registered repository.
  spec.requirements << "system: libpq: debian: libpq-dev"

  # Install PostgreSQL's Yum repository on RHEL family platforms:
  spec.requirements << "system: libpq: rhel: repository: id: pgdg17"
  spec.requirements << "system: libpq: rhel: repository: name: PostgreSQL 17 $releasever - $basearch"
  spec.requirements << "system: libpq: rhel: repository: baseurl: https://download.postgresql.org/pub/repos/yum/17/redhat/rhel-$releasever-$basearch"
  spec.requirements << "system: libpq: rhel: repository: gpgkey: https://download.postgresql.org/pub/repos/yum/keys/PGDG-RPM-GPG-KEY-RHEL"
  # You can disable built-in "postgresql" module by "module: disable:
  # postgresql".
  spec.requirements << "system: libpq: rhel: module: disable: postgresql"
  # Install postgresql17-devel from the registered repository. But
  # users can't find "libpq.pc" provided by postgresql17-devel without
  # PKG_CONFIG_PATH=/usr/pgsql-17/lib/pkgconfig ...
  spec.requirements << "system: libpq: rhel: postgresql17-devel"

  # ...
end
```

### Executable dependency

Dependency (the `DEPENDENCY` part in `system: DEPENDENCY: ...`) is
package ID of pkg-config by default. But you can use an executable as
dependency. For example, [graphviz
gem](https://rubygems.org/gems/graphviz) uses the `dot` command. It
means that the `dot` command is a runtime dependency of graphviz gem.

We can use rubygems-requirements-system for this use case. We can use
`executable(name)` for the `DEPENDENCY` part:

```ruby
Gem::Specification.new do |spec|
  # ...

  # Install dot before this gem is installed.
  spec.requirements << "system: executable(dot): alt_linux: graphviz"
  spec.requirements << "system: executable(dot): arch_linux: graphviz"
  spec.requirements << "system: executable(dot): conda: graphviz"
  spec.requirements << "system: executable(dot): debian: graphviz"
  spec.requirements << "system: executable(dot): gentoo_linux: media-gfx/graphviz"
  spec.requirements << "system: executable(dot): homebrew: graphviz"
  spec.requirements << "system: executable(dot): macports: graphviz"
  spec.requirements << "system: executable(dot): rhel: graphviz"

  # ...
end
```


## Configurations

### Disable

If you want to install system packages automatically, you need to
install rubygems-requirements-system gem explicitly (opt-in). You can
disable rubygems-requirements-system gem even when you install this
explicitly:

1. Set `RUBYGEMS_REQUIREMENTS_SYSTEM=false`
2. Add the following configuration to `~/.gemrc`:

   ```yaml
   requirements_system:
     enabled: false
   ```

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
