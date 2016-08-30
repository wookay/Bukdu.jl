# module Bukdu.Plug

type Static
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

type StaticController <: ApplicationController
end

function read(c::StaticController)
    path = c[:private][:path]
    resp = FileResponse(path)
    params = Dict{String,String}()
    query_params = Dict{String,String}()
    Conn(resp.status, Dict{String,String}(resp.headers), resp.data, params, query_params)
end

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
            path = joinpath(root, file)
            opts = Dict(:private => Dict{Symbol,Any}(:path=>path))
            if "index.html" == file
                Routing.match(get, "/", StaticController, read, opts)
            end
            if has_only
                !any(x->startswith(path, x), only) && continue
            end
            reqpath = path[length(from)+1:end]
            Routing.match(get, reqpath, StaticController, read, opts)
        end
    end
end
