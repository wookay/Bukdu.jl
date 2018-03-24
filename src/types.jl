# module Bukdu

export ApplicationController
export Render, JSON

abstract type ApplicationController end

mutable struct JSON{T}
    content::T
end

mutable struct Javascript{T}
    content::T
end

struct Render
    content_type::String
    body::Vector{UInt8}
end

# module Bukdu
