# parent module Bukdu

function render(::Type{Val{:Markdown}}, text::String)::String
    chomp(Markdown.html(Markdown.parse(text)))
end

function render{AL<:ApplicationLayout}(::Type{Val{:Markdown}}, L::Type{AL}, text::String)::String
    body = chomp(Markdown.html(Markdown.parse(text)))
    method_exists(layout, (L,String,Dict)) ? layout(L(), body, Dict()) : body
end
