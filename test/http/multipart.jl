module test_http_multipart

using Test
using HTTP: Multipart

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

# https://discourse.julialang.org/t/http-multipart-form-data-processing-by-server/24076/3
reqbody = """
-----------------------------182023285717490760841965583652
Content-Disposition: form-data; name="image"; filename="file1.jpg"
Content-Type: image/jpeg

......JFIF.............C..........
-----------------------------182023285717490760841965583652
Content-Disposition: form-data; name="num"

2
-----------------------------182023285717490760841965583652--
"""
boundary = "---------------------------182023285717490760841965583652"
scanner = FormScanner(Vector{UInt8}(reqbody), string("--", boundary))
body_params = scan(scanner)

@test  body_params[1][1] == "image"
multipart = body_params[1][2]
@test multipart isa Multipart
@test String(read(multipart.data)) == "......JFIF.............C.........."

@test body_params[2] == ("num" => "2")

end # module test_http_multipart
