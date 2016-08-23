function render(::Type{Val{:Markdown}}, text::String)::String
    chomp(Markdown.html(Markdown.parse(text)))
end
