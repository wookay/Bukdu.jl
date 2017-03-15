# module Bukdu

module Naming

function resource_name(alias, suffix = "")::String
    # Base.datatype_name
    underscore(unsuffix(string(Base.datatype_name(alias)), suffix))
end

function unsuffix(value::String, suffix::String)::String
    endswith(value, suffix) ? value[1:end-length(suffix)] : value
end

function underscore(value::String)::String
    # TODO
    lowercase(value)
end

end # module Bukdu.Naming
