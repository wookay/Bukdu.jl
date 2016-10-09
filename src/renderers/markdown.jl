# module Bukdu

function render(T::Type{Val{:Markdown}}, args...)::Conn
    filtering(render,T,args...) do
        text = isempty(args) ? "": first(args)
        Conn(200, Dict("Content-Type"=>"text/html"), chomp(Markdown.html(Markdown.parse(text))))
    end
end
