# module Bukdu

function render(T::Type{Val{:Markdown}}, text::String)::String
    filtering(render,T,text) do
        chomp(Markdown.html(Markdown.parse(text)))
    end
end
