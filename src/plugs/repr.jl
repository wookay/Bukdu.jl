# module Bukdu.Plug

function simple_el(x::AbstractString)::String
    string('"', x, '"')
end

function simple_el(x)
    x
end

function simple_repr(pair::Pair)::String
    string(Pair, '(', simple_el(pair.first), ", ", simple_el(pair.second), ')')
end

function simple_repr(pairs::Vector{<:Pair})::String
    string('[', join(simple_repr.(pairs), ", "), ']')
end

function simple_repr(x)
    x
end

# module Bukdu.Plug
