# module Bukdu.Plug

"""
    Plug.Static
"""
struct Static <: AbstractPlug
end

import ..Bukdu: ApplicationController, Conn, Render

struct StaticController <: ApplicationController
    conn::Conn
end

"""
    plug(::Type{Static}; at::String, from::String)
"""
function plug(::Type{Static}; at::String, from::String)
    function readfile(c::StaticController)
        reqpath = c.conn.request.target
        offset = isdirpath(at) ? 1 : 2
        targetpath = reqpath[length(at)+offset:end]
        filepath = joinpath(from, targetpath)
        (_, fileext) = splitext(filepath)
        ext = lowercase(fileext)
        if ext in (".html", ".htm")
            s = open(read, filepath)
            Render("text/html; charset=utf-8", s)
        else
            # FIXME: stream
            s = open(read, filepath)
            if ext in (".wasm",)
                Render("application/wasm", s)
            else
                Render("application/octet-stream", s)
            end
        end
    end
    for (root, dirs, files) in walkdir(from)
         subpath = root[length(from)+1:end]
         for filename in files
             reqpath = normpath(at, subpath, filename)
             get(reqpath, StaticController, readfile)
        end
    end
end

# module Bukdu.Plug
