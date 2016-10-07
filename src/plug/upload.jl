# module Bukdu.Plug

immutable Upload
    filename::String
    content_type::String
    data::Vector{UInt8}

    Upload() = new("", "application/octet-stream", Vector{UInt8}())
    Upload(filename::String, content_type::String, data::Vector{UInt8}) = new(filename, content_type, data)
end


module UploadData

import ..Upload
import ....Bukdu
import Bukdu: Assoc, Logger

settings = Assoc()

function plugged()
    !isempty(settings)
end

function make_tmp_dir(; kw...)
    for (k,v) in kw
        settings[k] = v
    end
    tmp_dir = settings[:tmp_dir]
    if !isdir(tmp_dir)
        mkdir(tmp_dir)
        Logger.debug() do
            string(Logger.with_color(:blue, "UPLOAD"), " created ", Logger.with_color(:bold, tmp_dir))
        end
    end
end

function tmp_name(upload::Upload)
    string(hash(upload.data), '-', upload.filename)
end

function save(upload::Upload)::Bool
    !haskey(settings, :tmp_dir) && return false
    isempty(upload.filename) && return false
    tmp_dir = settings[:tmp_dir]
    filename = tmp_name(upload)
    filepath = joinpath(tmp_dir, filename)
    open(filepath, "w") do f
        write(f, upload.data)
        Logger.debug() do
            sep = Base.Filesystem.path_separator
            string(Logger.with_color(:blue, "UPLOAD"), " A temporary file saved to ", basename(tmp_dir), sep, Logger.with_color(:bold, filename), " (", sizeof(upload), ")")
        end
    end
    return true
end

function upload_path(upload::Upload)
    joinpath(settings[:at], tmp_name(upload))
end

function upload_filepath(path::String)
    tmp_dir = settings[:tmp_dir]
    filename = basename(path)
    normpath(tmp_dir, filename)
end

function sizeof(upload::Upload)::String
    len = length(upload.data)
    (bytes, mb) = Base.prettyprint_getunits(len, length(Base._mem_units), Int64(1000))
    suffix = (1 == mb) ? "s" : ""
    string(replace(string(round(bytes, 1)), ".0", ""), ' ', Base._mem_units[mb], suffix)
end

end # Bukdu.Plug.UploadData

import Base: ==

==(lhs::Upload, rhs::Upload) =
    ==(lhs.filename, rhs.filename) &&
    ==(lhs.content_type, rhs.content_type) &&
    ==(lhs.data, rhs.data)

default(T::Type, ::Type{Upload}) = Upload()

function strong(x)
    "<strong>$x</strong>"
end

function Base.show(stream::IO, mime::MIME"text/html", upload::Plug.Upload)
    write(stream, string("Plug.Upload("))
    write(stream, string("filename: ", strong(upload.filename), ", "))
    write(stream, string("content_type: ", strong(upload.content_type), ", "))
    write(stream, string("filesize: ", strong(UploadData.sizeof(upload)), ", "))
    len = length(upload.data)
    if len > 6
        write(stream, string("data: ", eltype(upload.data), "[",
            join(map(repr, upload.data[1:3]), ", "), ", ... ",
            join(map(repr, upload.data[end-2:end]), ", "), "]"))
    else
        write(stream, repr(upload.data))
    end
    write(stream, string(")"))
end

function Base.show(stream::IO, mime::MIME"text/html", tup::Tuple{Symbol,Plug.Upload})
    for x in tup
        if isa(x, Plug.Upload)
            show(stream, mime, x)
        else
            write(stream, string("(:", strong(x), ", "))
        end
    end
    write(stream, string(")"))
end

function read_at_tmp_dir(c::StaticController)
    filepath = UploadData.upload_filepath(c[:path])
    resp = FileResponse(filepath)
    Conn(resp.status, Dict{String,String}(resp.headers), resp.data)
end

"""
plug `Plug.Upload` further processing file uploads.

```julia
Endpoint() do
    plug(Plug.Upload, at="/upload", tmp_dir="tmp")
end
```
"""
function plug(::Type{Plug.Upload}; kw...)
    # at::String, tmp_dir::String
    UploadData.make_tmp_dir(; kw...)
    opts = Dict{Symbol,Any}(kw)
    Routing.matchall(get, opts[:at], StaticController, read_at_tmp_dir, opts)
end
