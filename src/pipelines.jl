# module Bukdu

import Base: pipeline

"""
    pipeline(block::Function, routers...)
"""
function pipeline(block::Function, pipes...)
    for pipe::Symbol in pipes
        pipelines = get(Routing.routing_pipelines, pipe, [])
        push!(pipelines, block)
        Routing.routing_pipelines[pipe] = pipelines
    end
end

# module Bukdu
