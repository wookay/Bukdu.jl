# module Bukdu

import Base: reload

abstract ApplicationEndpoint

immutable Endpoint <: ApplicationEndpoint
end

module EndpointManagement
import ..Route
endpoint_routes = Dict{Type,Vector{Route}}()
endpoint_contexts = Dict{Type,Function}()
end # module Bukdu.EndpointManagement


function reload{AE<:ApplicationEndpoint}(E::Type{AE})
    context = EndpointManagement.endpoint_contexts[E]
    empty!(RouterRoute.routes)
    context()
    EndpointManagement.endpoint_routes[E] = copy(RouterRoute.routes)
    nothing
end

function (E::Type{AE}){AE<:ApplicationEndpoint}(context::Function)
    empty!(RouterRoute.routes)
    context()
    EndpointManagement.endpoint_routes[E] = copy(RouterRoute.routes)
    EndpointManagement.endpoint_contexts[E] = context
    nothing
end

function (E::Type{AE}){AE<:ApplicationEndpoint}(path::String)
    routes = haskey(EndpointManagement.endpoint_routes,E) ? EndpointManagement.endpoint_routes[E] : Vector{Route}()
    Routing.request(routes, |, path) do route
        true
    end
end
