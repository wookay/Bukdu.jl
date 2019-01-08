# module Bukdu.Plug

struct Parsers <: AbstractPlug
end

"""
    plug(::Type{Parsers}; parsers::Vector{Symbol})
"""
function plug(::Type{Parsers}; parsers::Vector{Symbol})
    ContentParsers.content_parsers[:default] = parsers
end

# module Bukdu.Plug
