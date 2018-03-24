# module Bukdu.Plug

struct Static <: AbstractPlug
end

import ..Bukdu: ApplicationController, Conn, Render

struct StaticController <: ApplicationController
    conn::Conn
end

function plug(::Type{Static}; at::String, from::String) # cache::Bool
    function readfile(c::StaticController)
        reqpath = c.conn.request.target
        filepath = normpath(from, reqpath[2:end])
        s = open(read, filepath)
        Render("application/octet-stream", s)
    end
    for (root, dirs, files) in walkdir(from)
        for filename in files
            filepath = normpath(root, filename)
            reqpath = normpath(at, filepath[length(from)+2:end])
            get(reqpath, StaticController, readfile)
        end
    end
end

# module Bukdu.Plug
