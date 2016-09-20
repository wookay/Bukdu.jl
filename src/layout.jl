# module Bukdu

import Base: /

abstract ApplicationLayout

immutable Layout <: ApplicationLayout
end

immutable LayoutDivision{AL<:ApplicationLayout}
    dividend::Union{Module,Type}
    divisor::Type{AL}
end

function viewlayout_symbol{AL<:ApplicationLayout}(D::LayoutDivision{AL})
    view_name = isa(D.dividend, Type) ? D.dividend.name.name : Base.module_name(D.dividend)
    layout_name = D.divisor.name.name
    Symbol(view_name, '/', layout_name)
end

function show{AL<:ApplicationLayout}(io::IO, D::LayoutDivision{AL})
    write(io, viewlayout_symbol(D))
end

function /{AL<:ApplicationLayout}(dividend::Union{Module,Type}, ::Type{AL})
    LayoutDivision{AL}(dividend, AL)
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
