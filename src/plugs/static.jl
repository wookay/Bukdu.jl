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
        ".js"   => "text/javascript",
        ".mjs"  => "text/javascript",
        ".wasm" => "application/wasm",
        ".css"  => "text/css",
    )
    get(mimes, ext, "application/octet-stream")
end

"""
    plug(::Type{Static}; at::String, from::String, only::Union{Vector{String},Nothing}=nothing, indexfile="index.html")
"""
function plug(::Type{Static}; at::String, from::String, only::Union{Vector{String},Nothing}=nothing, indexfile="index.html")
    function _readfile_base(c::StaticController, f)
        reqpath = c.conn.request.target
        offset = isdirpath(at) ? 1 : 2
        targetpath = reqpath[length(at)+offset:end]
        filepath = joinpath(f(from, targetpath)...)
        (_, fileext) = splitext(filepath)
        ext = lowercase(fileext)
        Render(content_type_for_file_extionsion(ext), read, filepath)
    end # function _readfile_base

    function readfile(c::StaticController)
        _readfile_base(c, (from, targetpath) -> (from, targetpath))
    end # function readfile

    function readindexfile(c::StaticController)
        _readfile_base(c, (from, targetpath) -> (from, targetpath, indexfile))
    end # function readindexfile

    has_only = only isa Vector{String} && !isempty(only)
    for (root, dirs, files) in walkdir(from)
         subpath = root[length(from)+1:end]
         for filename in files
             if has_only
                 subfilepath = normpath(subpath, filename)
                 !any(x->startswith(subfilepath, x), only) && continue # for filename
             end
             if filename == indexfile
                 reqindex = normpath(at, subpath)
                 get(reqindex, StaticController, readindexfile)
             end
             reqpath = normpath(at, subpath, filename)
             if Sys.iswindows()
                 path_arr = split(reqpath, Base.Filesystem.path_separator)
                 reqpath = join(path_arr, '/')
             end
             get(reqpath, StaticController, readfile)
        end
    end
end

# module Bukdu.Plug
