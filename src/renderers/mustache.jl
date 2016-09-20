# module Bukdu

import Mustache

function template(path::String, options::Dict)
    contents = chomp(readstring(path))
    Mustache.render(contents, options)
end

function render{AV<:ApplicationView}(::Type{AV}, args...; kw...)
    filtering(render, AV, args...) do
        options = Dict(kw)
        path = options[:path]
        template(path, options)
    end
end
