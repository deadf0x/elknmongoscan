description = [[ check elasticsearch. ]]

author = ""
license = "Same as Nmap--See https://nmap.org/book/man-legal.html"
categories = {"discovery", "version"}

local http = require "http"
local string = require "string"
local json = require "json"

portrule = function(host, port)
  return port.protocol == "tcp" and port.state == "open"
end

action = function(host, port)
  local uri = "/"
  local response = http.get(host, port, uri)
  if ( response.status == 200 ) then
    if ( string.find(response.body, "You Know, for Search") ) then
      local out = host.ip
      out = out .. "\n"
      err, esjson = json.parse(response.body)
      out = out .. "version: ".. esjson['version']['number'] .."\n"
      out = out .. "Indices found:\n"
      local resindices = http.get_url("http://"..host.ip..":"..port.number.."/_cat/indices?pri&v&h=index,docs.count")
      out = out .. resindices.body
      out = out .. "_________________________________\n"

      return out
    end
  end
end
