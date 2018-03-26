# module Bukdu

export ApplicationController
export Conn
export Render, JSON, JavaScript

import HTTP

"""
    ApplicationController
"""
abstract type ApplicationController end


### controllers

"""
    Conn
"""
struct Conn
    request::HTTP.Messages.Request
    params::Assoc
    query_params::Assoc
    body_params::Assoc
    path_params::Assoc
end

struct MissingController <: ApplicationController
    conn::Conn
end


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

# module Bukdu
