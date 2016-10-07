# module Bukdu.Server

import ..Assoc
import ..Plug
import ..Logger
import HttpCommon: Request

type FormScanner
    data::Vector{UInt8}
    offset::Int
    pos::Int
    boundary::String
    FormScanner(data::Vector{UInt8}, boundary::String) = new(data, 1, 1, boundary)
end

function empty_carriage_return(s::String)
    replace(s, '\r', "")
end

function empty_carriage_return(data::Vector{UInt8}, isfile::Bool)
    len = length(data)
    if len > 2
        if isfile
            [0x2d,0x2d]==data[end-1:end] ? data[1:end-5] : data[1:end-2]
        else
            [x for x in ([0x0d,0x0a]==data[1:2] ? data[3:end-4] : data[2:end-2]) if x!=0x0d]
        end
    else
        return Vector{UInt8}()
    end
end

function readData(s::FormScanner, len::Int, boundary::String, lf::UInt8, isfile::Bool)
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

function scan(s::FormScanner)::Assoc
    lf = 0x0a
    pat_filename = r"""Content-Disposition: form-data; name=\"(?P<name>[^\"]*)\"; filename=\"(?P<filename>[^\"]*)\""""
    pat = r"""Content-Disposition: form-data; name=\"(?P<name>[^\"]*)\""""
    len = length(s.data)
    name = nothing
    filename = nothing
    content_type = nothing
    assoc = Assoc()
    while s.pos < len
        if lf==s.data[s.pos]
            if isa(filename, Void)
                chunk = String(s.data[s.offset:s.pos])
                m_filename = match(pat_filename, chunk)
                if isa(m_filename, RegexMatch)
                    name = Symbol(m_filename[:name])
                    filename = String(m_filename[:filename])
                else
                    m = match(pat, chunk)
                    if isa(m, RegexMatch)
                        name = Symbol(m[:name])
                        push!(assoc, (name, String(readData(s, len, s.boundary, lf, false))))
                    end
                end
            else
                if isa(content_type, Void)
                    content_type = chomp(String(s.data[s.offset+length("Content-Type: ")+1:s.pos]))
                else
                    upload = Plug.Upload(filename, content_type, readData(s, len, s.boundary, lf, true))
                    Plug.UploadData.save(upload)
                    push!(assoc, (name, upload))
                    filename = nothing
                    content_type = nothing
                end
            end
            s.offset = s.pos
        end
        s.pos += 1
    end
    assoc
end

function post_form_data(req::Request)::Assoc
    if haskey(req.headers, "Content-Type") && startswith(req.headers["Content-Type"], "multipart/form-data")
        boundary = req.headers["Content-Type"][length("multipart/form-data; boundary=")+1:end]
        scanner = FormScanner(req.data, string("--",boundary))
        scan(scanner)
    else
        Assoc([(k, empty_carriage_return(v)) for (k,v) in parsequerystring(unescape_form(String(req.data)))])
    end
end
