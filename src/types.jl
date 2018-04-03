# module Bukdu

export JSON, JavaScript

struct JSON
end

struct JavaScript
end


### routes

struct Route
    C::Type{<:ApplicationController}
    action
    path_params::Vector{Pair{String,String}}
    pipelines::Vector{Function}
end

# module Bukdu
