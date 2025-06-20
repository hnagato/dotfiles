#!/usr/bin/env ruby

require 'pathname'
require 'optparse'

def error(msg)
  warn "ERROR: #{msg}"
  exit 1
end

class String
  def to_path
    Pathname.new(self).expand_path
  end
end  

class Pathname
  def / other
    case other
    when Pathname
      (self + other.basename.to_s).expand_path
    else
      (self + other.to_s).expand_path
    end
  end
  
  def basename?(name)
    case name
    when Regexp
      basename.to_s =~ name
    else
      basename.to_s == name.to_s
    end
  end
  
  def safe_symlink(target)
    if exist? && !symlink?
      error "Cannot create symlink: '#{self}' exists and is not a symlink"
    end
    
    unlink if symlink?
    make_symlink target
  end
  
  def mkdir_r
    return if exist?
    parent.mkdir_r unless parent.exist?
    mkdir unless exist?
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options]"
  opts.on('-t', '--test', 'Setup in /tmp instead of $HOME') { options[:test] = true }
  opts.on('-h', '--help', 'Show this help') { puts opts; exit }
end.parse!

target = (options[:test] ? "/tmp/#{ENV['USER']}" : ENV['HOME']).to_path
dotfiles = __FILE__.to_path.dirname.parent

target.mkdir_r

# Link dotfiles (skip special cases)
dotfiles.glob('.*').select(&:file?).each do |file|
  next if file.basename?(/^\.(git.*|config)$/)

  link = target/file
  link.safe_symlink(file)
end

# Link .config files (skip fish/nvim)
config_dir = target/'.config'
config_dir.mkdir_r

(dotfiles/'.config').glob('*') do |file|
  next if file.basename?(/^(fish|nvim)$/)
  
  link = config_dir/file
  link.safe_symlink(file)
end

# Setup fish
fish_dir = target/'.config/fish'
functions_dir = fish_dir/'functions'
[fish_dir, functions_dir].each(&:mkdir_r)

# Link fish config files (excluding functions directory)
(dotfiles/'.config/fish').glob('*').select(&:file?).each do |file|
  link = fish_dir/file
  link.safe_symlink(file)
end

# Link fish functions
(dotfiles/'.config/fish/functions').glob('*.fish').each do |file|
  link = functions_dir/file
  link.safe_symlink(file)
end

# Setup .ssh
ssh_dir = target/'.ssh'
ssh_dir.safe_symlink(dotfiles/'.ssh')
## chmod 600 .ssh/*
ssh_dir.glob('*').each do |file|
  file.chmod(0o600)
end