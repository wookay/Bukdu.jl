# parent module Bukdu

module Keyword

function get(dict::Dict, key::Symbol, default::Any)
    haskey(dict, key) ? dict[key] : default
end

end # module Keyword
