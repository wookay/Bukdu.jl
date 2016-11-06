# module Bukdu.Octo

module Inflector

function singularize(s::String)::String
    word = lowercase(s)
    m = match(r"(\w*)s", word)
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

function tableize(word::String)::String
    pluralize(underscore(word))
end

function underscore(word::String)::String
    join(matchall(r"([A-Z]+[a-z]*)", word), "_")
end

end # module Bukdu.Octo.Inflector
