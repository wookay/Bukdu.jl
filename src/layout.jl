# parent module Bukdu

import Base: /

abstract ApplicationLayout

type LayoutDivision{AL<:ApplicationLayout}
    dividend::Union{Module,Type}
    divisor::Type{AL}
end

type Layout <: ApplicationLayout
end

function /{AL<:ApplicationLayout}(dividend::Union{Module,Type}, ::Type{AL})
    LayoutDivision{AL}(dividend, AL)
end

function draw_layout{AL<:ApplicationLayout}(L::Type{AL}, body, options)
    if isa(body, Conn)
        data = layout(L(), body.resp_body, options)
        body.resp_body = data
        body
    else
        layout(L(), body, options)
    end
end

"""
layout(::Layout, body, options)
"""
function layout
end
