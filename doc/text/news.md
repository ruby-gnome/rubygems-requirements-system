# News

## 0.1.5 - 2025-12-01

### Improvements

  * Updated bundled `pkg-config` gem to 1.6.5.

## 0.1.4 - 2025-11-26

### Improvements

  * Added support for Ruby installed by MSYS2. Note that this is not
    for Ruby installed by RubyInstaller. Ruby installed by
    RubyInstaller must use `msys2_mingw_dependencies` gemspec metadata
    instead of this.
    * GH-16
    * Patch by takuya kodama

### Thanks

  * takuya kodama

## 0.1.3 - 2025-09-03

### Improvements

  * Updated bundled `pkg-config` gem to 1.6.4.

## 0.1.2 - 2025-08-27

### Improvements

  * Updated bundled `pkg-config` gem to 1.6.3.

## 0.1.1 - 2025-06-11

### Fixes

  * arch-linux: Fixed a bug that MSYS2 is also detected.

## 0.1.0 - 2025-05-02

### Fixes

  * Fixed a bug that error log isn't reported.

## 0.0.9 - 2025-05-02

### Fixes

  * Fixed a typo.

## 0.0.8 - 2025-04-05

### Improvements

  * Added support for an executable as a dependency.

## 0.0.7 - 2025-03-22

### Fixes

  * pld-linux: Fixed a bug that interactive mode is used.

## 0.0.6 - 2025-03-20

### Fixes

  * Fixed Bundler integration.

## 0.0.5 - 2025-03-20

### Improvements

  * Improved Bundler integration.

## 0.0.4 - 2025-03-05

### Improvements

  * Bundled `pkg-config` gem.

  * Changed to opt-in style. Each user must install this gem
    explicitly.

  * Added support for Bundler.

## 0.0.3 - 2025-01-13

### Improvements

  * Added support for opt-out.

  * debian: Added support for adding APT repository by raw metadata.

  * fedora: Added support for adding Yum repository by raw metadata.

  * fedora: Added support for enabling/disabling module.

## 0.0.2 - 2025-01-08

### Improvements

  * debian: Added support for installing `.deb` via HTTPS.

  * ubuntu: Added support for PPA repository.

  * fedora: Added support for installing `.rpm` via HTTPS.

## 0.0.1 - 2025-01-08

Initial release!!!
