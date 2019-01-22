# module Bukdu.Plug

struct Parsers <: AbstractPlug
end

"""
    plug(::Type{Parsers}, decoders::Pair{Symbol,DataType}...; parsers::Vector{Symbol})
"""
function plug(::Type{Parsers}, decoders::Pair{Symbol,DataType}...; parsers::Vector{Symbol})
    ContentParsers.env[:decoders] = merge(ContentParsers.default_content_decoders, Dict{Symbol,DataType}(decoders...))
    ContentParsers.env[:parsers] = parsers
end

# module Bukdu.Plug
