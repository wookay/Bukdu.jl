# module Bukdu

import Mustache

function template(path::String, options::Dict)::String
    contents = chomp(readstring(path))
    Mustache.render(contents, options)
end

function render{AV<:ApplicationView}(::Type{AV}, args...; kw...)::Conn
    filtering(render, AV, args...) do
        options = Dict(kw)
        path = options[:path]
        Conn(200, Dict("Content-Type"=>"text/html"), template(path, options))
    end
end
