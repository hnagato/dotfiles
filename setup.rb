#!/usr/bin/env ruby

require 'pathname'
require 'fileutils'
require 'optparse'

include FileUtils::Verbose

opt = OptionParser.new
opt.on('-d', '--dry-run') {|v| include FileUtils::DryRun }
opt.parse!(ARGV)

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
BASE = File.dirname(__FILE__).expand

cd BASE do
  Pathname.glob('.*') do |dotfile|
    next if dotfile.to_s =~ /^\.{1,2}$/
    next if dotfile.to_s =~ /^\.(config|DS_Store|git(ignore|modules)?)$/
    next if dotfile.symlink?

    symlink BASE/dotfile, HOME/dotfile
  end

  Pathname.glob('.config/**/*') do |config|
    next if config.symlink? or config.directory?

    dir = (HOME/config).parent
    dir.mkpath unless dir.exist?

    symlink BASE/config, HOME/config
  end
end
