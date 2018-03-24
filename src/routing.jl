module Routing # Bukdu

import ..Bukdu: ApplicationController, MissingController, Conn, Naming
import ..Bukdu: HTTP

struct Route
    C::Type{<:ApplicationController}
    action
    path_params::Dict{String, String}
end

function handle(req::HTTP.Messages.Request)
    uri = HTTP.URI(req.target)
    segments = split(uri.path, '/')
    vals = [Val(Symbol(seg)) for seg in segments]
    route(Val(Symbol(req.method)), vals...)
end

function not_found(::MissingController)
    "not found"
end

route(args...) = Route(MissingController, not_found, Dict())

# idea from HTTP/src/Handlers.jl
function penetrate_segments(segments)
    vals = Expr[]
    path_params = Expr[]
    for seg in segments
        if startswith(seg, ':')
            param = seg[2:end]
            mangled = Symbol(param, :_)
            pair = :(Pair($param, String(first(typeof($mangled).parameters))))
            push!(path_params, pair)
            expr = :($mangled::Any)
        else
            expr = :(::Val{Symbol($seg)})
        end
        push!(vals, expr)
    end
    return (vals, path_params)
end

function add_route(verb, url::String, C::Type{<:ApplicationController}, action)
    segments = split(url, '/')
    (vals, path_params) = penetrate_segments(segments) 
    method = Naming.verb_name(verb)
    @eval route(::Val{Symbol($method)}, $(vals...)) = Route($C, $action, Dict($(path_params...)))
end

end # module Bukdu.Routing
