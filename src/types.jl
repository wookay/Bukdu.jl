# module Bukdu

"""
    Conn
"""
struct Conn
    request::HT.Request
end

"""
    ApplicationController
"""
abstract type ApplicationController end


module ContentTypes # Bukdu

struct JSON
end

using Base.Docs: Text, HTML

end # module Bukdu.ContentTypes

using .ContentTypes: JSON, Text, HTML

# module Bukdu
