# module Bukdu.Octo

function singularize(s::String)::String
    word = lowercase(s)
    m = match(r"/(\w*)s/", word)
    if isa(m, RegexMatch)
        return first(m.captures)
    else
        return word
    end
end

function pluralize(s::String)::String
    word = lowercase(s)
    string(word, "s")
end
