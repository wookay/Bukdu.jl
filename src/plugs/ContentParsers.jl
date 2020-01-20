module ContentParsers # Bukdu.Plug

using ...Deps.HTTP
using ...Deps.URIParser
using ...Deps: Request
using .HTTP.Messages: hasheader, header
using .HTTP: Multipart
using ...Bukdu: Route
using ..Plug
using JSON

abstract type AbstractDecoder end

struct JSONDecoder <: AbstractDecoder
end

struct MergedJSON <: AbstractDecoder
end

const default_content_decoders = Dict{Symbol,Type{<:AbstractDecoder}}(:json => MergedJSON)
const default_content_parsers = [:json, :urlencoded, :multipart]
env = Dict{Symbol, Union{Dict{Symbol,Type{<:AbstractDecoder}}, Vector{Symbol}}}(:decoders => default_content_decoders, :parsers => default_content_parsers)

# application/x-www-form-urlencoded

struct UrlEncodedScanner
    data::Vector{UInt8}
end

# https://github.com/JuliaWeb/HttpCommon.jl/blob/v0.2.6/src/HttpCommon.jl#L141
function scan(s::UrlEncodedScanner)::Vector{Pair{String,String}}
    query = String(s.data)
    ps = Vector{Pair{String,String}}()
    isempty(query) && return assoc
    for field in split(query, '&'; keepempty=false)
        (k, v) = split(field, '=')
        key = URIParser.unescape_form(k)
        value = URIParser.unescape_form(v)
        push!(ps, Pair(key, value))
    end
    ps
end


# multipart/form-data

mutable struct FormScanner
    data::Vector{UInt8}
    boundary::String
    FormScanner(data::Vector{UInt8}, boundary::String) = new(data, boundary)
end

const CR = 0x0d
const LF = 0x0a
const ContentDisposition = "Content-Disposition: form-data;"

function rstripcr(vec::Vector{UInt8})::Vector{UInt8}
    if !isempty(vec) && vec[end] == CR
        vec[1:end-1]
    else
        vec
    end
end

function rstripcrlf(vec::Vector{UInt8})::Vector{UInt8}
    if !isempty(vec) && vec[end] == LF
        rstripcr(vec[1:end-1])
    else
        vec
    end
end

function content_disposition_fields(io::IOBuffer)::Dict{String,String}
    fields = Dict{String,String}()
    str = String(readuntil(io, LF))
    h = rstripcr(readuntil(io, LF))
    if isempty(h)
    else
        (k, v) = split(String(h), ": ")
        fields[k] = v
        readuntil(io, LF)
    end
    pat = r" (?P<key>[^\"]*)=\"(?P<val>[^\"]*)\""
    for m in eachmatch(pat, str)
        fields[m[:key]] = m[:val]
    end
    fields
end

function scan(s::FormScanner)::Vector{Pair{String,Any}}
    ps = Vector{Pair{String, Any}}()
    io = IOBuffer(s.data, read=true, truncate=false)
    while !eof(io)
        chunk = readuntil(io, s.boundary)
        if !isempty(chunk)
            chunkio = IOBuffer(chunk)
            skipchars(==(Char(CR)), chunkio)
            skipchars(==(Char(LF)), chunkio)
            readuntil(chunkio, ContentDisposition)
            contentdisposition = rstripcrlf(read(chunkio))
            if !isempty(contentdisposition)
                contentio = IOBuffer(contentdisposition)
                fields = content_disposition_fields(contentio)
                name = fields["name"]
                if haskey(fields, "filename")
                    filename = fields["filename"]
                    contenttype = get(fields, "Content-Type", "")
                    # contenttransferencoding
                    multipart = Multipart(filename, contentio, contenttype)
                    push!(ps, Pair(name, multipart))
                else
                    value = read(contentio)
                    push!(ps, Pair(name, String(value)))
                end
            end
        end
    end
    ps
end

function parse(::Type{JSONDecoder}, buf::IOBuffer)::Vector{Pair{String,Any}}
    nt = JSON.parse(read(buf, String))
    return [Pair("json", nt)]
end

function parse(::Type{MergedJSON}, buf::IOBuffer)::Vector{Pair{String,Any}}
    nt = JSON.parse(read(buf, String))
    return [Pair(string(k),v) for (k,v) in pairs(nt)]
end

function fetch_body_params(req::Request)::Vector{Pair{String,Any}}
    if hasheader(req.headers, "Content-Type")
        content_type = header(req.headers, "Content-Type")
        request_decoders = env[:decoders]
        request_parsers = env[:parsers]
        if :json in request_parsers && "application/json" == content_type
            return parse(request_decoders[:json], IOBuffer(req.body))
        elseif :urlencoded in request_parsers && "application/x-www-form-urlencoded" == content_type
            scanner = UrlEncodedScanner(req.body)
            return scan(scanner)
        elseif :multipart in request_parsers && startswith(content_type, "multipart/form-data")
            pat = r"boundary=\"?([\W\w]*)\"?"
            m = match(pat, content_type)
            if m isa RegexMatch
                boundary = m[1]
                scanner = FormScanner(req.body, string("--", boundary))
                return scan(scanner)
            end
        end
    end
    Vector{Pair{String,Any}}()
end

end # module Bukdu.Plug.ContentParsers
