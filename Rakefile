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

require "bundler/gem_helper"
require "json"
require "open-uri"

base_dir = File.dirname(__FILE__)
helper = Bundler::GemHelper.new(base_dir)
def helper.version_tag
  version
end
helper.install

def github_api(path)
  URI("https://api.github.com/#{path}").open do |response|
    JSON.parse(response.read)
  end
end

def github_content(repository, tag, path, &block)
  uri = "https://raw.githubusercontent.com/#{repository}/" +
        "refs/tags/#{tag}/#{path}"
  URI(uri).open(&block)
end

namespace :vendor do
  namespace :pkg_config do
    desc "Update vendored pkg-config"
    task :update do
      latest = github_api("repos/ruby-gnome/pkg-config/releases/latest")
      github_content("ruby-gnome/pkg-config",
                     latest["tag_name"],
                     "lib/pkg-config.rb") do |response|
        output_path = "lib/rubygems-requirements-system/pkg-config.rb"
        File.open(output_path, "w") do |output|
          IO.copy_stream(response, output)
        end
      end
    end
  end
end

release_task = Rake.application["release"]
# We use Trusted Publishing.
release_task.prerequisites.delete("build")
release_task.prerequisites.delete("release:rubygem_push")
release_task_comment = release_task.comment
if release_task_comment
  release_task.clear_comments
  release_task.comment = release_task_comment.gsub(/ and build.*$/, "")
end
