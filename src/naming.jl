module Naming # moudle Bukdu

function resource_name(alias, suffix = "")::String
    underscore(unsuffix(string(nameof(alias)), suffix))
end

function unsuffix(value::String, suffix::String)::String
    ifelse(endswith(value, suffix), value[1:end-length(suffix)], value)
end

function underscore(value::String)::String
    lowercase(value)
end

function verb_name(verb)::String
    uppercase(string(nameof(verb)))
end

end # moudle Bukdu.Naming
