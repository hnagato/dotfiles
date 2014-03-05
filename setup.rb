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


# symlink
HOME = '~'.expand
BASE = File.dirname(__FILE__).expand
cd BASE do
  Pathname.glob('.*') do |dotfile|
    next if dotfile.to_s =~ /^\.{1,2}$/
    next if dotfile.to_s =~ /^\.(DS_Store|git(modules)?)$/
    next if dotfile.symlink?

    symlink dotfile, HOME/dotfile
  end

  symlink 'bin'.expand, '~/bin'.expand
end


# init neobundle.vim
#BUNDLE_DIR = '~/.vim/bundle'.expand
#unless (BUNDLE_DIR/'neobundle.vim').exists?
#  mkdir_p BUNDLE_DIR unless BUNDLE_DIR.directory?
#  cd BUNDLE_DIR do
#    system "git clone git://github.com/Shougo/neobundle.vim"
#    system 'vi -c "Unite neobundle/install:!"'
#  end
#end

# vim: ft=ruby
