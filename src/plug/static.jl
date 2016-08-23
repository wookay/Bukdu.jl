# parent module Plug

type Static
end

function plug{AR<:ApplicationRouter}(::Type{Plug.Static}, at::String, from::Type{AR}, only::Vector{String})
end
