# module Bukdu

function render(::Type{HTML}, obj::Any)::Conn
    filtering(render, HTML, obj) do
        Conn(200, Dict("Content-Type"=>"text/html"), obj)
    end
end

include("html/tag.jl")
