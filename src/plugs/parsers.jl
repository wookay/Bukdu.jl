# module Bukdu.Plug

struct Parsers <: AbstractPlug
end

"""
    plug(::Type{Parsers}, parsers::Vector{Symbol} = ContentParsers.default_content_parsers; decoders...)
"""
function plug(::Type{Parsers}, parsers::Vector{Symbol} = ContentParsers.default_content_parsers; decoders...)
    ContentParsers.env[:decoders] = merge(ContentParsers.default_content_decoders, Dict{Symbol,Type{<:ContentParsers.AbstractDecoder}}(decoders))
    decoder_symbols = Vector{Symbol}(first.(collect(decoders)))
    ContentParsers.env[:parsers] = union(parsers, decoder_symbols)
end

# module Bukdu.Plug
