# module Bukdu

export render

"""
    render
"""
function render
end

function render(::Type{Text}, data)::Render
    Render("text/plain; charset=utf-8", unsafe_wrap(Vector{UInt8}, string(data)))
end

function render(::Type{HTML}, data)::Render
    Render("text/html; charset=utf-8", unsafe_wrap(Vector{UInt8}, string(data)))
end

# import JSON2

function render(::Type{JSON}, data)::Render
    Render("application/json; charset=utf-8", unsafe_wrap(Vector{UInt8}, JSON2.write(data)))
end

# module Bukdu
