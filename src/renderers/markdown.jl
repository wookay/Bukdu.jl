# module Bukdu

function render(T::Type{Val{:Markdown}}, text::String)::Conn
    filtering(render,T,text) do
        Conn(200, Dict("Content-Type"=>"text/html"), chomp(Markdown.html(Markdown.parse(text))))
    end
end
