# module Bukdu

import Base: /

abstract ApplicationLayout

type Layout <: ApplicationLayout
end

type LayoutDivision{AL<:ApplicationLayout}
    dividend::Union{Module,Type}
    divisor::Type{AL}
end

function layout_symbol{AL<:ApplicationLayout}(D::LayoutDivision{AL})
    view = isa(D.dividend, Type) ? D.dividend.name.name : Base.module_name(D.dividend)
    lay = D.divisor.name.name
    Symbol(view, '/', lay)
end

function show{AL<:ApplicationLayout}(io::IO, D::LayoutDivision{AL})
    write(io, layout_symbol(D))
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
