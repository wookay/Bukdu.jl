# module Bukdu

export ApplicationController
export Conn
export Render, JSON

import HTTP

abstract type ApplicationController end
abstract type ApplicationRouter     end


### controller

struct Conn
    path_params::Dict{String, String}
    request::HTTP.Messages.Request
end

struct MissingController <: ApplicationController
    conn::Conn
end


### render

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
