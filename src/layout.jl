# parent module Bukdu

import Base: /

abstract ApplicationLayout

type LayoutDivision{AL<:ApplicationLayout}
    dividend::Union{Module,Type}
    divisor::Type{AL}
end

type Layout <: ApplicationLayout
end

type VoidLayout <: ApplicationLayout
end

function /{AL<:ApplicationLayout}(dividend::Union{Module,Type}, ::Type{AL})
    LayoutDivision{AL}(dividend, AL)
end

"""
layout(::Layout, body, options)
"""
function layout
end
