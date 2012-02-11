#!/usr/bin/env ruby -Ku
# -*- coding: utf-8 -*-

module Keychain
  require 'open3'

  def self.get_password server, user, protocol
    _, _, err = Open3.popen3("/usr/bin/security find-internet-password -s #{server} -a #{user} -r #{protocol} -g")
    if /^password: "(.*)"$/ === err.gets
      $1
    else
      nil
    end
  end
end

