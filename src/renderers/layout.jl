# module Bukdu

import Base: /

immutable Layout <: ApplicationLayout
end

immutable LayoutDivision{AL<:ApplicationLayout}
    dividend::Union{LayoutDivision,Module,Type}
    divisor::Type{AL}
end

function viewlayout_symbol{AL<:ApplicationLayout}(D::LayoutDivision{AL})
    view_name = isa(D.dividend, LayoutDivision) ? viewlayout_symbol(D.dividend) :
                isa(D.dividend, Type) ? get_datatype_name(D.dividend):
                Base.module_name(D.dividend)
    layout_name = get_datatype_name(D.divisor)
    Symbol(view_name, '/', layout_name)
end

function Base.show{AL<:ApplicationLayout}(io::IO, D::LayoutDivision{AL})
    write(io, viewlayout_symbol(D))
end

function /{AL<:ApplicationLayout}(dividend::Union{Module,Type}, ::Type{AL})
    LayoutDivision{AL}(dividend, AL)
end

function /{AL<:ApplicationLayout}(division::LayoutDivision, ::Type{AL})
    LayoutDivision{AL}(division, AL)
end


"""
    layout(::Layout, body)

Set the outer content for the `Layout`.

```julia
julia> layout(::Layout, body) = "<html><body>\$body</body></html>"
```
"""
function layout
end
