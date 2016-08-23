# parent module Bukdu

import Mustache

function template(path::String, options::Dict)
    contents = chomp(readstring(path))
    Mustache.render(contents, options)
end

function render{AV<:ApplicationView}(V::Type{AV}; kw...)
    render(V, VoidLayout; kw...)
end

function render{AL<:ApplicationLayout,AV<:ApplicationView}(V::Type{AV}, L::Type{AL}; kw...)
    options = Dict(kw)
    path = options[:path]
    body = template(path, options)
    method_exists(layout, (L,String,Dict)) ? layout(L(), body, options) : body
end
