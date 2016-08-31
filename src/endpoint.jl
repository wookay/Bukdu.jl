# module Bukdu

abstract ApplicationEndpoint

immutable Endpoint <: ApplicationEndpoint
end


function (E::Type{AE}){AE<:ApplicationEndpoint}(context::Function)
    empty!(RouterRoute.routes)
    context()
    Routing.endpoint_map[E] = copy(RouterRoute.routes)
end

function (E::Type{AE}){AE<:ApplicationEndpoint}(path::String)
    routes = haskey(Routing.endpoint_map,E) ? Routing.endpoint_map[E] : Vector{Route}()
    Routing.request(routes, |, path) do route
        true
    end
end
