# module Bukdu

function render(::Type{HTML}, md::Base.Markdown.MD)::Conn
    render(HTML, stringmime("text/html", md))
end

function render(::Type{HTML}, obj::Any)::Conn
    filtering(render, HTML, obj) do
        Conn(200, Dict("Content-Type"=>"text/html"), obj)
    end
end

include("html/tag.jl")
