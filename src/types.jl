# module Bukdu

export ApplicationController
export Conn
export Render, JSON, JavaScript


### controllers

"""
    ApplicationController
"""
abstract type ApplicationController end


# follow the https://github.com/elixir-plug/plug/blob/master/lib/plug/conn.ex
"""
    Conn
"""
mutable struct Conn
    request::Deps.Request

    # Fetchable fields
    # cookies           # the request cookies with the response cookies  FIXME
    body_params::Assoc  # Plug.Parsers
    query_params::Assoc # fetch_query_params
    path_params::Assoc
    params::Assoc       # merge(body_params, query_params, path_params)

    # Connection fields
    halted::Bool        # the boolean status on whether the pipeline was halted
end
Conn(request::Deps.Request) = Conn(request, Assoc(), Assoc(), Assoc(), Assoc(), false)


### renders

"""
    Render
"""
struct Render
    content_type::String
    body::Vector{UInt8}
end

mutable struct JSON{T}
    content::T
end

mutable struct JavaScript{T}
    content::T
end


### routes

struct Route
    C::Type{<:ApplicationController}
    action
    path_params::Vector{Pair{String,String}}
    pipelines::Vector{Function}
end

# module Bukdu
