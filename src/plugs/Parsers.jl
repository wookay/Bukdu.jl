module Parsers # Bukdu.Plug

import ...Deps: HTTP, URIParser, Request

# application/x-www-form-urlencoded

struct UrlEncodedScanner
    data::Vector{UInt8}
end

# https://github.com/JuliaWeb/HttpCommon.jl/blob/v0.2.6/src/HttpCommon.jl#L141
function scan(s::UrlEncodedScanner)::Vector{Pair{String,String}}
    query = String(s.data)
    ps = Vector{Pair{String,String}}()
    isempty(query) && return assoc
    for field in split(query, '&'; keep=false)
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
    offset::Int
    pos::Int
    boundary::String
    FormScanner(data::Vector{UInt8}, boundary::String) = new(data, 1, 1, boundary)
end

function empty_carriage_return(data::Vector{UInt8}, isfile::Bool)::Vector{UInt8}
    len = length(data)
    if len > 2
        if isfile
            [0x2d,0x2d] == data[end-1:end] ? data[1:end-5] : data[1:end-2]
        else
            [x for x in ([0x0d,0x0a] == data[1:2] ? data[3:end-4] : data[2:end-2]) if x != 0x0d]
        end
    else
        return Vector{UInt8}()
    end
end

function readData(s::FormScanner, len::Int, boundary::String, lf::UInt8, isfile::Bool)::Vector{UInt8}
    s.offset = s.pos+1
    offset_begin = s.offset
    len_boundary = length(boundary)
    while s.pos < len
        if lf==s.data[s.pos] || s.pos==len-1
            chunk = String(s.data[s.offset+1:s.pos])
            if startswith(chunk, boundary)
                data = s.data[offset_begin:s.pos-len_boundary]
                s.offset = s.pos
                return empty_carriage_return(data, isfile)
            end
            s.offset = s.pos
        end
        s.pos += 1
    end
end

function scan(s::FormScanner)::Vector{Pair{String,String}}
    lf = 0x0a
    pat_filename = r"""Content-Disposition: form-data; name=\"(?P<name>[^\"]*)\"; filename=\"(?P<filename>[^\"]*)\""""
    pat = r"""Content-Disposition: form-data; name=\"(?P<name>[^\"]*)\""""
    len = length(s.data)
    name = nothing
    filename = nothing
    content_type = nothing
    ps = Vector{Pair{String, String}}()
    while s.pos < len
        if lf==s.data[s.pos]
            if isa(filename, Nothing)
                chunk = String(s.data[s.offset:s.pos])
                m_filename = match(pat_filename, chunk)
                if isa(m_filename, RegexMatch)
                    name = m_filename[:name]
                    filename = String(m_filename[:filename])
                else
                    m = match(pat, chunk)
                    if isa(m, RegexMatch)
                        name = m[:name]
                        push!(ps, Pair(name, String(readData(s, len, s.boundary, lf, false))))
                    end
                end
            else
                if isa(content_type, Nothing)
                    content_type = String(chomp(String(s.data[s.offset+length("Content-Type: ")+1:s.pos])))
                else
                    #upload = Plug.Upload(filename, content_type, readData(s, len, s.boundary, lf, true))
                    #Plug.UploadData.save(upload)
                    upload = ""
                    push!(ps, Pair(name, upload))
                    filename = nothing
                    content_type = nothing
                end
            end
            s.offset = s.pos
        end
        s.pos += 1
    end
    ps 
end


function fetch_body_params(req::Request)::Vector{Pair{String,String}}
    if HTTP.Messages.hasheader(req.headers, "Content-Type")
        content_type = HTTP.Messages.header(req.headers, "Content-Type")
        if "application/x-www-form-urlencoded" == content_type
            scanner = UrlEncodedScanner(req.body)
            return scan(scanner)
        elseif startswith(content_type, "multipart/form-data")
            boundary = content_type[length("multipart/form-data; boundary=")+1:end]
            scanner = FormScanner(req.body, string("--",boundary))
            return scan(scanner)
        end
    end
    Vector{Pair{String,String}}()
end

end # module Bukdu.Plug.Parsers
