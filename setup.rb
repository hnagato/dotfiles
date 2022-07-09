#!/usr/bin/env ruby -Ku
# -*- coding: utf-8 -*-

require 'rubygems'
require 'pathname'
require 'fileutils'

# include FileUtils::DryRun
include FileUtils::Verbose

class String
  def expand
    Pathname.new(self).expand_path
  end
end

class Pathname
  def / other
    (self + other).expand_path
  end

  def to_bak
    (self.realpath.to_s + '.org').expand
  end
end

def symlink src, dest
  # backup or remove
  if dest.exist?
    if dest.symlink?
      rm dest
    else
      mv dest, dest.to_bak
    end
  end
  ln_sf src.expand_path, dest
end


HOME = '~'.expand

Pathname.glob('.*') do |dotfile|
  next if dotfile.to_s =~ /^\.{1,2}$/
  next if dotfile.to_s =~ /^\.(config|DS_Store|git(ignore|modules)?)$/
  next if dotfile.symlink?

  symlink dotfile, HOME/dotfile
end

%w(
  .config/starship.toml
  .config/fish/config.fish
  .config/peco/config.json 
).each do |path|
  symlink path.expand, HOME/path
end


# vim: ft=ruby
