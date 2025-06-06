#!/usr/bin/env ruby

require 'fileutils'
require 'pathname'
require 'optparse'

include FileUtils::Verbose

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
    return if symlink? && readlink == target
    rmtree if exist?
    make_symlink(target)
  end
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options]"
  opts.on('-t', '--test', 'Setup in /tmp instead of $HOME') { options[:test] = true }
  opts.on('-h', '--help', 'Show this help') { puts opts; exit }
end.parse!

target = (options[:test] ? "/tmp/#{ENV['USER']}" : ENV['HOME']).to_path
dotfiles = __FILE__.to_path.dirname

mkdir_p target

# Link dotfiles (skip special cases)
dotfiles.glob('.*').select(&:file?).each do |file|
  next if file.basename?(/^\.(git.*|config)$/)

  link = target/file
  link.safe_symlink(file)
end

# Link .config files (skip fish/nvim)
config_dir = target/'.config'
mkdir_p config_dir

(dotfiles/'.config').glob('*') do |file|
  next if file.basename?(/^(fish|nvim)$/)
  
  link = config_dir/file
  link.safe_symlink(file)
end

# Setup fish
fish_dir = target/'.config/fish'
functions_dir = fish_dir/'functions'
[fish_dir, functions_dir].each(&method(:mkdir_p))

(dotfiles/'.config/fish').glob('*').select(&:file?).each do |file|
  link = file.basename?('fish_greeting.fish') ? functions_dir/file : fish_dir/file
  link.safe_symlink(file)
end
