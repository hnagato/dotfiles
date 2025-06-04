#!/usr/bin/env ruby

require 'fileutils'
require 'pathname'
require 'optparse'
require 'open3'

def error(msg)
  warn "ERROR: #{msg}"
  exit 1
end

# Parse options
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options]"
  opts.on('-t', '--test', 'Setup in /tmp instead of $HOME') { options[:test] = true }
  opts.on('-h', '--help', 'Show this help') { puts opts; exit }
end.parse!

target = Pathname(options[:test] ? "/tmp/#{ENV['USER']}" : ENV['HOME'])
dotfiles = Pathname(__FILE__).dirname.expand_path

target.mkpath

# Link dotfiles (skip special cases)
dotfiles.glob('{.*,*}').each do |file|
  next unless file.exist?
  next if file == dotfiles || file == dotfiles.parent || file.symlink?
  next if file.basename.to_s =~ /^(README\.md|setup\.(sh|rb)|\.git.*|\.config)$/
  
  link = target / file.basename
  next if link.symlink? && link.readlink == file
  link.rmtree if link.exist?
  link.make_symlink(file)
end

# Link .config files (skip fish/nvim)
config_dir = target / '.config'
config_dir.mkpath

(dotfiles / '.config').glob('*').each do |file|
  next unless file.exist?
  next if file.basename.to_s =~ /^(fish|nvim)$/
  
  link = config_dir / file.basename
  next if link.symlink? && link.readlink == file
  link.rmtree if link.exist?
  link.make_symlink(file)
end

# Setup fish
fish_dir = target / '.config/fish'
functions_dir = fish_dir / 'functions'
[fish_dir, functions_dir].each(&:mkpath)

(dotfiles / '.config/fish').glob('*').select(&:file?).each do |file|
  link = file.basename.to_s == 'fish_greeting.fish' ? functions_dir / file.basename : fish_dir / file.basename
  next if link.symlink? && link.readlink == file
  link.rmtree if link.exist?
  link.make_symlink(file)
end

# Install fisher plugins
_, _, status = Open3.capture3('command -v fish')
error "fish not installed" unless status.success?

fisher_cmd = 'curl -sL git.io/fisher | source && fisher update'
env = options[:test] ? {'HOME' => target.to_s} : {}
_, _, status = Open3.capture3(env, "fish -c '#{fisher_cmd}'")
error "fisher failed" unless status.success?

# Setup nvim submodule
Dir.chdir(dotfiles) do
  nvim_git = dotfiles / '.config/nvim/.git'
  unless nvim_git.exist?
    _, _, status = Open3.capture3('git submodule init .config/nvim')
    error "submodule init failed" unless status.success?
    _, _, status = Open3.capture3('git submodule update .config/nvim')
    error "submodule update failed" unless status.success?
  end
end

Dir.chdir(dotfiles / '.config/nvim') do
  _, _, status1 = Open3.capture3('git pull origin main')
  _, _, status2 = Open3.capture3('git pull origin master') unless status1.success?
  error "nvim pull failed" unless status1.success? || status2.success?
end

nvim_link = target / '.config/nvim'
nvim_source = dotfiles / '.config/nvim'
unless nvim_link.symlink? && nvim_link.readlink == nvim_source
  nvim_link.rmtree if nvim_link.exist?
  nvim_link.make_symlink(nvim_source)
end
