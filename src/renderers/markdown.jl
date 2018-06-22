# module Bukdu

function render(T::Type{Val{:Markdown}}, args...)::Conn
    filtering(render, T, args...) do
        text = isempty(args) ? "": first(args)
        Conn(:ok, Dict("Content-Type"=>"text/html"), chomp(Markdown.html(Markdown.parse(text)))) # 200
    end
end
