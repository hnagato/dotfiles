#!/usr/bin/env ruby -Ku
# -*- coding: utf-8 -*-

$: << File.dirname(__FILE__)

require 'rubygems'
load("config/environment.rb")

def @FILE@
end

if $0 == __FILE__
  @FILE@
end

__END__
