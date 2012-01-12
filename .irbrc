require 'irb/completion'
require 'pp'
require 'rubygems'
require 'wirble'

Wirble.init
Wirble.colorize

IRB.conf[:SAVE_HISTORY] = 128
IRB.conf[:AUTO_INDENT] = true
IRB.conf[:PROMPT_MODE] = :SIMPLE

module Kernel
  def r(arg)
    puts `refe #{arg}`
  end
  private :r
end

class Module
  def r(meth = nil)
    if meth
      if instance_methods(false).include? meth.to_s
        puts `refe #{self}##{meth}`
      else
        super
      end
    else
      puts `refe #{self}`
    end
  end
end

#:vim set ft=ruby

