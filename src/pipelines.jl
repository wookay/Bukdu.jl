# module Bukdu

import Base: pipeline

"""
    pipeline(block::Function, routers...)
"""
function pipeline(block::Function, routers...)
    for router::Symbol in routers
        pipelines = get(Routing.router_pipelines, router, [])
        push!(pipelines, block)
        Routing.router_pipelines[router] = pipelines
    end
end

# module Bukdu
