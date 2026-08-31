# module Bukdu

struct Conn
    req::HT.Request
end

"""
    ApplicationController
"""
abstract type ApplicationController end


module ContentTypes # Bukdu

struct JSON
end

using Base.Docs: Text

end # module Bukdu.ContentTypes
using .ContentTypes: JSON, Text

# module Bukdu
