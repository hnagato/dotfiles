#!/usr/bin/env ruby

require 'pathname'

class String
  def to_path
    Pathname.new(self).expand_path
  end
end

class Pathname
  def / other
    (self + other.to_s).expand_path
  end

  def mkdir_r
    return self if exist?
    parent.mkdir_r
    mkdir
    self
  end
end

target_root = if ARGV.delete('-t')
  user = ENV['USER'] || ENV['LOGNAME'] || 'user'
  "/tmp/#{user}"
else
  ENV['TARGET'] || ENV['HOME']
end

TARGET = target_root.to_path.mkdir_r
dotfiles = __FILE__.to_path.dirname

TRASH = (TARGET/'.Trash'/"dotfiles_#{Time.now.strftime('%Y%m%d-%H%M%S')}").mkdir_r

def move_to_trash(dest)
  rel = dest.relative_path_from(TARGET)
  target = TRASH/rel
  target.parent.mkdir_r
  dest.rename(target)
  puts "Moved: #{dest} -> #{target}"
end

def link_path(src, dest)
  if dest.exist? || dest.symlink?
    move_to_trash(dest)
  end
  dest.parent.mkdir_r
  dest.make_symlink(src)
rescue SystemCallError => e
  warn "WARN: failed to link #{dest} (#{e.message})"
end

dotfiles.glob('{.config/*,.*}').each do |file|
  next if file == dotfiles || file == dotfiles.parent
  next if file.to_s =~ %r{/\.(?:config|git|gitignore)$}

  link_path(file, TARGET/file.relative_path_from(dotfiles))
end
