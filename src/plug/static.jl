# module Bukdu.Plug

immutable Static
end

import HttpServer: Response, mimetypes
import ..Octo: Assoc

function FileResponse(filename)
    if isfile(filename)
        s = open(Base.read, filename)
        (_, ext) = splitext(filename)
        mime = length(ext)>1 && haskey(mimetypes, ext[2:end]) ? mimetypes[ext[2:end]] : "application/octet-stream"
        Response(200, Dict{AbstractString,AbstractString}([("Content-Type",mime)]), s)
    else
        Response(404, "Not Found - file $filename could not be found")
    end
end


import ..ApplicationController, ..Conn, ..Routing

type StaticController <: ApplicationController
    conn::Conn
end

function read(c::StaticController)
    filepath = c[:assigns][:filepath]
    resp = FileResponse(filepath)
    Conn(resp.status, Dict{String,String}(resp.headers), resp.data)
end

"""
plug `Plug.Static` to serve the static files.

```julia
Endpoint() do
    plug(Plug.Static, at="/", from="public")
end
```
"""
function plug(::Type{Plug.Static}; kw...)
    # at::String, from::String, only::Vector{String})
    opts = Dict(kw)
    at = opts[:at]
    from = opts[:from]
    if haskey(opts, :only)
        only = opts[:only]
        has_only = !isempty(only)
    else
        has_only = false
    end
    for (root, dirs, files) in walkdir(from)
        for filename in files
            filepath = joinpath(root, filename)
            if has_only
                !any(x->startswith(filepath, normpath(from, x)), only) && continue
            end
            opts = Dict(:assigns => Assoc(filepath=filepath))
            if root == from && "index.html" == filename
                Routing.match(get, "/", StaticController, read, opts)
            end
            reqpath = joinpath(at, filepath[length(from)+2:end])
            if is_windows()
                reqpath = replace(reqpath, '\\', '/')
            end
            Routing.match(get, reqpath, StaticController, read, opts)
        end
    end
end
