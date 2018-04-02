module Parsers # Bukdu.Plug

import ...Deps: HTTP, URIParser, Request
import .HTTP.Messages: hasheader, header


# getindex_header

function getindex_header(headers::Vector{Pair{String,String}}, key::String)::Union{String,Nothing}
    if hasheader(headers, key)
        header(headers, key)
    else
        nothing
    end
end


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

function scan(s::FormScanner)::Vector{Pair{String,String}}
    ps = Vector{Pair{String, String}}()
    io = IOBuffer(s.data, read=true, truncate=false)
    while !eof(io)
        chunk = readuntil(io, s.boundary)
        if !isempty(chunk)
            chunkio = IOBuffer(chunk)
            skip(chunkio, CR)
            skip(chunkio, LF)
            contentdisposition = readuntil(chunkio, ContentDisposition)
            if !isempty(contentdisposition)
            contentio = IOBuffer(contentdisposition)
            fields = content_disposition_fields(contentio)
            value = String(rstripcrlf(read(contentio)))
            push!(ps, Pair(fields["name"], value))
            end
        end
    end
    ps
end

function fetch_body_params(req::Request)::Vector{Pair{String,String}}
    if hasheader(req.headers, "Content-Type")
        content_type = header(req.headers, "Content-Type")
        if "application/x-www-form-urlencoded" == content_type
            scanner = UrlEncodedScanner(req.body)
            return scan(scanner)
        elseif startswith(content_type, "multipart/form-data")
            pat = r"boundary=\"?([\W\w]*)\"?"
            m = match(pat, content_type)
            if m isa RegexMatch
                boundary = m[1]
                scanner = FormScanner(req.body, string("--", boundary))
                return scan(scanner)
            end
        end
    end
    Vector{Pair{String,String}}()
end

end # module Bukdu.Plug.Parsers
