# module Bukdu.Plug

struct Static <: AbstractPlug
end

struct StaticController <: ApplicationController
    conn::Conn
end

function content_type_for_file_extionsion(ext)::String
    mimes = Dict(
        ".html" => "text/html; charset=utf-8",
        ".htm"  => "text/html; charset=utf-8",
        ".wasm" => "application/wasm",
        ".css"  => "text/css",
    )
    get(mimes, ext, "application/octet-stream")
end

"""
    plug(::Type{Static}; at::String, from::String, only::Union{Vector{String},Nothing}=nothing)
"""
function plug(::Type{Static}; at::String, from::String, only::Union{Vector{String},Nothing}=nothing)
    function readfile(c::StaticController)
        reqpath = c.conn.request.target
        offset = isdirpath(at) ? 1 : 2
        targetpath = reqpath[length(at)+offset:end]
        filepath = joinpath(from, targetpath)
        (_, fileext) = splitext(filepath)
        ext = lowercase(fileext)
        # FIXME: stream
        s = open(read, filepath)
        Render(content_type_for_file_extionsion(ext), s)
    end # function readfile
    has_only = only isa Vector{String} && !isempty(only)
    for (root, dirs, files) in walkdir(from)
         subpath = root[length(from)+1:end]
         for filename in files
             if has_only
                 subfilepath = normpath(subpath, filename)
                 !any(x->startswith(subfilepath, x), only) && continue # for filename
             end
             reqpath = normpath(at, subpath, filename)
             get(reqpath, StaticController, readfile)
        end
    end
end

# module Bukdu.Plug
