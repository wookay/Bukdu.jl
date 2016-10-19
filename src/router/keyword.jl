# module Bukdu

module Keyword

import ..Assoc

function get(dict::Union{Dict,Assoc}, key::Union{Symbol,String}, default::Any)
    haskey(dict, key) ? dict[key] : default
end

end # module Bukdu.Keyword
