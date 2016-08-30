# module Bukdu

abstract ApplicationEndpoint

immutable Endpoint <: ApplicationEndpoint
end


function (E::Type{AE}){AE<:ApplicationEndpoint}(context::Function)
    routes = copy(RouterRoute.routes)
    empty!(RouterRoute.routes)
    context()
    append!(RouterRoute.routes, routes)
end

function (E::Type{AE}){AE<:ApplicationEndpoint}(path::String)
    Routing.request(path) do route
        true
    end
end
