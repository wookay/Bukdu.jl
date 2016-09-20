# module Bukdu.Plug

immutable Static
end

import HttpServer: Response, mimetypes

function FileResponse(filename)
    if isfile(filename)
        s = open(Base.read, filename)
        (_, ext) = splitext(filename)
        mime = length(ext)>1 && haskey(mimetypes,ext[2:end]) ? mimetypes[ext[2:end]] : "application/octet-stream"
        Response(200, Dict{AbstractString,AbstractString}([("Content-Type",mime)]), s)
    else
        Response(404, "Not Found - file $filename could not be found")
    end
end


import ..ApplicationController, ..Routing, ..Conn

immutable StaticController <: ApplicationController
end

function read(c::StaticController)
    filepath = c[:assigns][:filepath]
    resp = FileResponse(filepath)
    params = Dict{String,String}()
    query_params = Dict{String,String}()
    private = Dict{Symbol,String}()
    assigns = Dict{Symbol,String}()
    Conn(resp.status, Dict{String,String}(resp.headers), resp.data, params, query_params, private, assigns)
end

"""
plug `Plug.Static` to serve the static files.

```julia
Endpoint() do
    plug(Plug.Static, at= "/", from= "public")
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
        for file in files
            filepath = joinpath(root, file)
            opts = Dict(:assigns => Dict{Symbol,String}(:filepath=>filepath))
            if "index.html" == file
                Routing.match(get, "/", StaticController, read, opts)
            end
            if has_only
                !any(x->startswith(filepath, x), only) && continue
            end
            reqpath = filepath[length(from)+1:end]
            Routing.match(get, reqpath, StaticController, read, opts)
        end
    end
end
