#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# Firefox
begin
  require 'net/telnet'
  telnet = Net::Telnet.new({
     "Host" => "localhost",
     "Port" => 4242
  })
  telnet.puts("content.location.reload(true)")
  telnet.close
rescue => e
end


# Safari
<<`EOC`
osascript -e '
tell application "Safari"
  do JavaScript "location.reload(true);" in document 1
end tell
'
EOC

# Chrome
`osascript -e 'tell application "Google Chrome" to reload active tab of window 1'`

